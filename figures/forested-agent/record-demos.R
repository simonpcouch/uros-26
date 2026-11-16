# Records one continuous conversation with the forested commons agent, the way
# the original commons demos were screen-recorded, plus a log of when each
# event happened. `edit-demos.R` cuts and zooms the recording into clips.
record_forested_demo <- function(
  url = "http://127.0.0.1:8765",
  output_dir = "figures/raw",
  prefix = "forested-agent"
) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  frame_dir <- tempfile(paste0(prefix, "-frames-"))
  dir.create(frame_dir)

  state <- new.env(parent = emptyenv())
  state$files <- character()
  state$times <- numeric()
  state$events <- list()
  state$frame_dir <- frame_dir

  browser <- chromote::ChromoteSession$new()
  on.exit(browser$close(), add = TRUE)
  # The original recordings were 3340x1874: a 1670x937 window on a Retina display.
  browser$Emulation$setDeviceMetricsOverride(
    width = 1670,
    height = 937,
    deviceScaleFactor = 2,
    mobile = FALSE
  )
  browser$Page$addScriptToEvaluateOnNewDocument(source = page_setup_js)
  browser$go_to(paste0(url, "?recording=", format(Sys.time(), "%H%M%S")))
  wait_for_js(browser, "document.querySelectorAll('.suggestion').length > 0")
  # The greeting settles into place after the suggestions first appear.
  pump_browser(3)

  # Screencast frames ignore the device scale factor, so capture screenshots
  # back to back instead.
  state$capturing <- TRUE
  capture_loop(browser, state)

  card <- element_center(browser, ".suggestion", last = FALSE)
  cursor <- list(x = card$x - 150, y = card$y + 40)
  draw_cursor(browser, cursor)
  pump_browser(1.5)

  # Turn 1: click the suggestion, then press Enter.
  log_event(state, "turn1_cursor_start")
  card <- element_center(browser, ".suggestion", last = FALSE)
  cursor <- glide_mouse(browser, state, cursor, card, duration = 0.6)
  pump_browser(0.15)
  with_capture_paused(browser, state, click_at(browser, card))
  wait_for_js(browser, "document.querySelector('[aria-label=\"Chat message\"]').innerText.trim().length > 0")
  log_event(state, "turn1_prompt_done")
  pump_browser(0.35)
  press_enter(browser)
  log_event(state, "turn1_send")
  cursor <- finish_turn(browser, state, "turn1", "Trusted", cursor)

  # Turns 2 and 3: type the question, then press Enter.
  turns <- list(
    list(id = "turn2", question = "Isn't the mean of the whole column different?", marker = "Untrusted"),
    list(id = "turn3", question = "Why is that different from the official number?", marker = "documentation")
  )
  for (turn in turns) {
    pump_browser(1.5)
    focus_input(browser)
    log_event(state, paste0(turn$id, "_type_start"))
    type_question(browser, turn$question)
    log_event(state, paste0(turn$id, "_prompt_done"))
    typed <- browser$Runtime$evaluate("document.querySelector('[aria-label=\"Chat message\"]').innerText.trim()", returnByValue = TRUE)$result$value
    if (!identical(typed, turn$question)) {
      cli::cli_abort("Typed {.val {typed}} rather than {.val {turn$question}}.")
    }
    pump_browser(0.12)
    press_enter(browser)
    log_event(state, paste0(turn$id, "_send"))
    cursor <- finish_turn(browser, state, turn$id, turn$marker, cursor)
  }

  pump_browser(1)
  state$capturing <- FALSE
  pump_browser(0.5)

  video <- file.path(output_dir, paste0(prefix, "-raw.mp4"))
  encode_frames(state$files, state$times, video)
  # Kept until here so a failed encode can be retried from the frames.
  unlink(frame_dir, recursive = TRUE)

  t0 <- state$times[[1]]
  events <- vapply(state$events, \(t) round(t - t0, 3), numeric(1))
  jsonlite::write_json(
    as.list(events),
    file.path(output_dir, paste0(prefix, "-events.json")),
    auto_unbox = TRUE,
    pretty = TRUE,
    digits = NA
  )
  cli::cli_inform("Wrote {.file {video}} ({length(state$files)} frames).")
  invisible(events)
}

# Waits for the answer, then hovers its provenance marker until the popup opens.
finish_turn <- function(browser, state, id, marker, cursor) {
  answers_before <- answer_count(browser)
  wait_for_js(browser, sprintf("document.querySelectorAll('.shiny-chat-message-body > p').length > %d", answers_before), timeout = 180)
  log_event(state, paste0(id, "_answer_start"))
  selector <- sprintf('button[aria-label="%s"]', marker)
  wait_for_js(browser, sprintf("!!document.querySelector('%s')", selector), timeout = 180)
  wait_for_stable(browser)
  log_event(state, paste0(id, "_answer_done"))

  pump_browser(1.5)
  log_event(state, paste0(id, "_hover_start"))
  target <- element_center(browser, selector, scroll = FALSE)
  cursor <- glide_mouse(browser, state, cursor, target, duration = 0.9)
  log_event(state, paste0(id, "_hover"))
  pump_browser(2.5)

  # Move off the marker so its popup closes before the next turn.
  glide_mouse(browser, state, cursor, list(x = cursor$x + 160, y = cursor$y + 60), duration = 0.5)
}

page_setup_js <- "
document.addEventListener('DOMContentLoaded', () => {
  const style = document.createElement('style');
  // The original app had no page header.
  style.textContent = 'header.shiny-chat-page-header { display: none !important; } ' +
    'shiny-chat-page { grid-template-rows: minmax(0, 1fr) !important; }';
  document.head.appendChild(style);

  // Headless Chrome draws no cursor, so draw one.
  const cursor = document.createElement('div');
  cursor.id = 'demo-cursor';
  cursor.innerHTML = '<svg width=\"18\" height=\"26\" viewBox=\"0 0 18 26\"><path d=\"M1.5 1.5 L1.5 20 L6 15.6 L9.2 23.2 L12.2 21.9 L9.1 14.5 L15.2 14.5 Z\" fill=\"black\" stroke=\"white\" stroke-width=\"1.5\" stroke-linejoin=\"round\"/></svg>';
  Object.assign(cursor.style, {
    position: 'fixed', left: '0', top: '0', zIndex: '2147483647',
    pointerEvents: 'none', transform: 'translate(-100px, -100px)'
  });
  document.body.appendChild(cursor);
  window.drawDemoCursor = (x, y) => {
    cursor.style.transform = `translate(${x - 1.5}px, ${y - 1.5}px)`;
  };
});
"

capture_loop <- function(browser, state) {
  if (!isTRUE(state$capturing)) {
    return(invisible())
  }
  state$in_flight <- TRUE
  requested <- as.numeric(Sys.time())
  promise <- browser$Page$captureScreenshot(
    format = "jpeg",
    quality = 90,
    optimizeForSpeed = TRUE,
    wait_ = FALSE
  )
  promises::then(promise, function(screenshot) {
    # Stamp each frame halfway between request and response.
    save_frame(screenshot$data, (requested + as.numeric(Sys.time())) / 2, state)
    state$in_flight <- FALSE
    capture_loop(browser, state)
  })
  invisible()
}

# Chrome drops mouse input that arrives during a screenshot, so real mouse
# events are sent between frames. The previous frame holds meanwhile.
with_capture_paused <- function(browser, state, code) {
  state$capturing <- FALSE
  while (isTRUE(state$in_flight)) {
    later::run_now(0.005)
  }
  force(code)
  pump_browser(0.05)
  state$capturing <- TRUE
  capture_loop(browser, state)
}

log_event <- function(state, name) {
  state$events[[name]] <- as.numeric(Sys.time())
}

save_frame <- function(data, timestamp, state) {
  path <- file.path(state$frame_dir, sprintf("frame-%05d.jpg", length(state$files) + 1L))
  writeBin(base64enc::base64decode(data), path)
  state$files <- c(state$files, path)
  state$times <- c(state$times, timestamp)
}

type_question <- function(browser, question) {
  # Roughly the original typing pace: about 0.11 seconds per character.
  for (character in strsplit(question, "", fixed = TRUE)[[1]]) {
    browser$Input$insertText(text = character)
    pump_browser(stats::runif(1, 0.07, 0.15))
  }
}

focus_input <- function(browser) {
  browser$Runtime$evaluate("document.querySelector('[aria-label=\"Chat message\"]').focus()")
}

press_enter <- function(browser) {
  for (type in c("keyDown", "keyUp")) {
    browser$Input$dispatchKeyEvent(
      type = type,
      key = "Enter",
      code = "Enter",
      windowsVirtualKeyCode = 13,
      nativeVirtualKeyCode = 13,
      text = if (type == "keyDown") "\r" else NULL
    )
  }
}

answer_count <- function(browser) {
  browser$Runtime$evaluate(
    "document.querySelectorAll('.shiny-chat-message-body > p').length",
    returnByValue = TRUE
  )$result$value
}

element_center <- function(browser, selector, scroll = TRUE, last = TRUE) {
  script <- sprintf(
    "(() => {
      const els = document.querySelectorAll(%s);
      const el = %s ? els[els.length - 1] : els[0];
      if (!el) return null;
      if (%s) el.scrollIntoView({block: 'center'});
      const r = el.getBoundingClientRect();
      return {x: r.left + r.width / 2, y: r.top + r.height / 2};
    })()",
    jsonlite::toJSON(selector, auto_unbox = TRUE),
    if (last) "true" else "false",
    if (scroll) "true" else "false"
  )
  center <- browser$Runtime$evaluate(script, returnByValue = TRUE)$result$value
  if (is.null(center)) {
    cli::cli_abort("Could not find {.val {selector}}.")
  }
  center
}

draw_cursor <- function(browser, point) {
  browser$Runtime$evaluate(sprintf("window.drawDemoCursor(%f, %f)", point$x, point$y))
}

# Animates the drawn cursor, then moves the real mouse to the destination so
# hover styles and popups respond.
glide_mouse <- function(browser, state, from, to, duration) {
  steps <- max(2, round(duration * 60))
  for (i in seq_len(steps)) {
    p <- (1 - cos(pi * i / steps)) / 2
    draw_cursor(browser, list(x = from$x + (to$x - from$x) * p, y = from$y + (to$y - from$y) * p))
    pump_browser(duration / steps)
  }
  with_capture_paused(
    browser,
    state,
    browser$Input$dispatchMouseEvent(type = "mouseMoved", x = to$x, y = to$y)
  )
  to
}

click_at <- function(browser, point) {
  for (type in c("mousePressed", "mouseReleased")) {
    browser$Input$dispatchMouseEvent(
      type = type,
      x = point$x,
      y = point$y,
      button = "left",
      clickCount = 1
    )
  }
}

wait_for_js <- function(browser, condition, timeout = 30) {
  started <- Sys.time()
  repeat {
    done <- browser$Runtime$evaluate(condition, returnByValue = TRUE)$result$value
    if (isTRUE(done)) {
      return(invisible())
    }
    if (elapsed_seconds(started) > timeout) {
      cli::cli_abort("Timed out waiting for {.code {condition}}.")
    }
    pump_browser(0.05)
  }
}

# Waits until the page text stops changing, i.e. the response finished streaming.
wait_for_stable <- function(browser, stable_for = 0.5, timeout = 60) {
  started <- Sys.time()
  last_change <- started
  previous <- ""
  repeat {
    text <- browser$Runtime$evaluate("document.body.innerText", returnByValue = TRUE)$result$value
    if (!identical(text, previous)) {
      previous <- text
      last_change <- Sys.time()
    }
    if (elapsed_seconds(last_change) >= stable_for) {
      return(invisible())
    }
    if (elapsed_seconds(started) > timeout) {
      cli::cli_abort("Timed out waiting for the response to finish.")
    }
    pump_browser(0.05)
  }
}

pump_browser <- function(seconds) {
  deadline <- Sys.time() + seconds
  while (Sys.time() < deadline) {
    later::run_now(0.01)
  }
}

elapsed_seconds <- function(started) {
  as.numeric(difftime(Sys.time(), started, units = "secs"))
}

# Holds each frame until the next one arrived, so the video keeps real time.
encode_frames <- function(files, timestamps, output, fps = 60) {
  durations <- c(diff(timestamps), 1 / fps)
  manifest <- tempfile(fileext = ".txt")
  on.exit(unlink(manifest), add = TRUE)
  writeLines(
    c(
      rbind(
        sprintf("file '%s'", normalizePath(files)),
        sprintf("duration %.6f", durations)
      ),
      sprintf("file '%s'", normalizePath(utils::tail(files, 1)))
    ),
    manifest
  )
  status <- system2("ffmpeg", c(
    "-y", "-loglevel", "error",
    "-f", "concat", "-safe", "0", "-i", shQuote(manifest),
    "-vf", shQuote(sprintf("fps=%d,format=yuv420p", fps)),
    "-an", "-c:v", "libx264", "-preset", "medium", "-crf", "16",
    shQuote(output)
  ))
  if (!identical(status, 0L)) {
    cli::cli_abort("FFmpeg failed to encode {.file {output}}.")
  }
}

if (sys.nframe() == 0L) {
  record_forested_demo()
}
