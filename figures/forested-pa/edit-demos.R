# Cuts the forested Posit Assistant recording into the demo clips, using the
# same holds, zoom depths, zoom offsets, and split points as the flights clips
# (see `~/Desktop/posit-assistant-demo-new/*.sh` and conf-26's "split Posit
# Assistant demo videos" and "remove still time" commits). Effect timings are
# anchored to events in the recording, since this take runs at a different
# pace than the flights one.
edit_pa_demos <- function(
  raw = "figures/raw/forested-pa-demo-compressed.mp4",
  output_dir = "figures",
  full_dir = "figures/raw",
  costs = "figures/costs.png",
  fps = 60
) {
  ev <- pa_events()
  for (clip in pa_clips(ev, costs, fps)) {
    render_pa_clip(clip, raw, output_dir, full_dir, fps)
  }
  # The full window at 01's first frame, shown before cutting to its zoom. The
  # recording runs 82 px past the window's right edge, in black.
  first_frame(
    raw,
    file.path(output_dir, "pa-01-webfetch-full-window.png"),
    time = ev$typed1,
    filter = "crop=3316:ih:0:0"
  )
  first_frame(
    file.path(output_dir, "pa-01-webfetch-a.mp4"),
    file.path(output_dir, "pa-01-webfetch-first-frame.png")
  )
  invisible()
}

# Times (in seconds) of events in the forested recording, read off of frame
# differences. Comments give the matching event in the flights recording.
pa_events <- function() {
  list(
    typed1 = 5.850,    # "Find an R package" after deleting a typo
    send1 = 11.533,    # flights 3.733
    done1 = 15.217,    # flights 8.683
    type2 = 17.900,    # flights 10.700
    send2 = 19.300,    # flights 13.950
    scroll2 = 20.750,  # the second prompt starts scrolling up
    # The tool output overflows the 2.3x frame; flights 19.0, when the second
    # tool call did.
    output2 = 21.883,
    both2 = 22.450,    # both tool results visible, prompt at the top
    # Cursor movements toward the next click begin at these times.
    move3 = 25.100,    # toward "Clean the data."
    move3a = 35.683,   # toward the first answer
    move3b = 37.983,   # toward "Submit Answers"
    move3c = 41.117,   # toward the second answer
    move4 = 50.150,    # toward the plot suggestion
    send4 = 51.617,    # flights 67.633
    text4 = 56.417,    # flights 74.817, interpretation pushes the plot up
    mid4 = 57.400,     # interpretation and docs tool call both visible
    done4 = 58.517,    # flights 78.983
    type5 = 62.067,    # flights 80.850
    done5 = 70.683,    # flights 89.850, report "done!"
    scroll5 = 72.933   # report is scrolled to its (empty) last line
  )
}

pa_clips <- function(ev, costs, fps) {
  # Output frame of a source time, relative to a clip start.
  frame <- function(time, start) round((time - start) * fps)
  # Clips end just before the cursor starts moving.
  before <- function(time) time - 2 / fps
  w <- 3398
  h <- 1868
  # The bottom crop 02 ends in, 03 holds, and 05 leaves. The flights clips used
  # 1.8x; 1.5x keeps the whole cleaning question in frame.
  crop <- c(z = 1.5, x = 0, y = 1 - 1 / 1.5)

  # 01: open on the composer once the prompt's typo is fixed, pan up as it's
  # sent, widening so the whole response fits, then zoom out over a held
  # second.
  s01 <- ev$typed1
  e01 <- ev$done1 + 1.817
  last01 <- frame(e01, s01) - 1
  pan01 <- frame(ev$send1, s01) - 20

  # 02: follow the second prompt and what's below it, pause where both tool
  # results show, zoom out, then settle into the bottom crop 03 continues.
  s02 <- ev$type2 - 0.2
  e02 <- before(ev$move3)
  zoom02 <- frame(ev$send2, s02) - 3
  scroll02 <- frame(ev$scroll2, s02)
  out02 <- frame(ev$output2, s02)
  pause02 <- frame(ev$both2, s02)
  # Hold the paused frame for a second once the framing settles.
  hold02 <- out02 + 48 + 60 - pause02
  full02 <- pause02 + hold02 + 1
  end02 <- frame(e02, s02) + hold02

  # 03: the cleaning turn, held in 02's bottom crop throughout.
  s03 <- e02
  e03 <- before(ev$move4)

  # 05: from 03's crop to the full view once sent, a tight crop on the
  # completed plot, a 2x crop on the first interpretation, then on the last.
  s05 <- e03
  e05 <- ev$done4 + 1.517
  open05 <- frame(ev$send4, s05) + 7
  plot05 <- frame(ev$text4, s05) - 20
  mid05 <- frame(ev$mid4, s05) + 60
  final05 <- frame(e05, s05) - 1 + 60 + 167

  # 06: bottom-aligned close-up through "done!", then the full view. The
  # flights clip cut 59 frames of pane navigation here; this take opens the
  # report in the full editor on its own, so there's nothing to cut. It ends
  # before the report is scrolled to its last line.
  s06 <- ev$type5 - 0.35
  e06 <- ev$scroll5 - 0.033
  out06 <- frame(ev$done5 + 0.42, s06)

  list(
    list(
      name = "pa-01-webfetch",
      start = s01,
      end = e01,
      filters = c(
        demo_freeze_filter(last01, 60, fps),
        # The flights clip panned to 0.04 at 2.3x; the response here is taller
        # and sits lower, so the pan widens to 2x at 0.125.
        demo_keyframe_filter(
          rbind(
            c(0, 2.3, 0, 0.565217),
            c(pan01, 2.3, 0, 0.565217),
            c(pan01 + 18, 2, 0, 0.125),
            c(last01 + 1, 2, 0, 0.125),
            c(last01 + 60, 1, 0, 0)
          ),
          w, h, fps
        )
      ),
      splits = last01 + 1 - 60
    ),
    list(
      name = "pa-02-docs",
      start = s02,
      end = e02,
      filters = c(
        demo_freeze_filter(pause02, hold02, fps),
        demo_keyframe_filter(
          rbind(
            c(zoom02, 1, 0, 0),
            # Bottom-aligned, so the prompt is at the top as it's sent.
            c(zoom02 + 48, 2.3, 0, 0.565217),
            c(scroll02, 2.3, 0, 0.565217),
            c(scroll02 + 30, 2.3, 0, 0.48),
            # Widen as the output arrives, settling on the paused frame.
            c(out02, 2.3, 0, 0.48),
            c(out02 + 48, 1.3, 0, 0.11),
            c(full02, 1.3, 0, 0.11),
            c(full02 + 59, 1, 0, 0),
            c(end02 - 1 - 48, 1, 0, 0),
            c(end02 - 1, crop[["z"]], crop[["x"]], crop[["y"]])
          ),
          w, h, fps
        )
      ),
      splits = out02 + 48 + 30
    ),
    list(
      name = "pa-03-clean-data",
      start = s03,
      end = e03,
      filters = demo_zoom_transition_filter(
        0, 48, crop[["z"]], crop[["z"]], 0, 0, crop[["y"]], crop[["y"]], w, h, fps
      ),
      splits = c(
        frame(before(ev$move3a), s03),
        frame(before(ev$move3b), s03),
        frame(before(ev$move3c), s03)
      )
    ),
    list(
      name = "pa-05-plot",
      start = s05,
      end = e05,
      filters = c(
        demo_zoom_transition_filter(
          open05, open05 + 48, crop[["z"]], 1, 0, 0, crop[["y"]], 0, w, h, fps
        ),
        demo_freeze_filter(plot05, 60, fps),
        # The flights clip used 0.27. The plotting tool sits higher and runs
        # taller here, so 0.225 keeps its header and the whole plot in frame.
        demo_zoom_filter(plot05 - 59, plot05 - 11, plot05 + 61, plot05 + 109, 1.83, 0.225, w, h, fps),
        # Not in the flights clip: pause on the first interpretation, with the
        # same freeze and zoom as the final one.
        demo_freeze_filter(mid05, 167, fps),
        demo_zoom_at_filter(mid05, mid05 + 48, mid05 + 108, mid05 + 167, 2, 0, 0.4, w, h, fps),
        demo_freeze_filter(final05, 239, fps),
        demo_zoom_at_filter(final05, final05 + 48, final05 + 180, final05 + 239, 2, 0, 0.333, w, h, fps)
      ),
      splits = c(plot05 + 31, mid05 + 48 + 30, final05 + 61, final05 + 61 + 89),
      # Drops the closing zoom-out, as in "remove still time".
      drop_tail = TRUE
    ),
    list(
      name = "pa-06-report",
      start = s06,
      end = e06,
      filters = demo_zoom_at_filter(0, 48, out06, out06 + 48, 2.5, 0, 0.6, w, h, fps),
      splits = integer()
    ),
    # The recording's chat pane was too narrow to show the running cost, so
    # this uses a screenshot from a wider pane (3304x1826). Its status row is
    # wider than the flights one, so the zoom is 3.4x rather than 4.65x.
    list(
      name = "pa-08-model-cost",
      source = costs,
      filters = c(
        demo_freeze_filter(0, 227, fps),
        demo_zoom_in_filter(0, 48, 3.4, 0.018, 0.702, 3304, 1826, fps)
      ),
      splits = integer()
    )
  )
}

render_pa_clip <- function(clip, raw, output_dir, full_dir, fps) {
  if (!is.null(clip$source)) {
    raw <- clip$source
  }
  clip_filter <- if (!is.null(clip$start)) {
    demo_clip_filter(clip$start, clip$end, fps)
  }
  filter <- paste(c(clip_filter, clip$filters), collapse = ",")
  if (length(clip$splits) == 0) {
    output <- file.path(output_dir, paste0(clip$name, ".mp4"))
    demo_render_video(raw, output, filter)
  } else {
    output <- file.path(full_dir, paste0(clip$name, ".mp4"))
    demo_render_video(raw, output, filter)
    split_video(
      output, clip$splits, file.path(output_dir, clip$name),
      drop_tail = isTRUE(clip$drop_tail)
    )
  }
  cli::cli_inform("Rendered {.file {clip$name}}; splits at frames {clip$splits}.")
}

# Writes `prefix-a.mp4`, `prefix-b.mp4`, ... for the frames between cuts.
split_video <- function(path, cuts, prefix, drop_tail = FALSE) {
  bounds <- c(0, cuts, if (!drop_tail) Inf)
  for (i in seq_len(length(bounds) - 1)) {
    output <- paste0(prefix, "-", letters[[i]], ".mp4")
    trim <- if (is.finite(bounds[[i + 1]])) {
      sprintf("trim=start_frame=%d:end_frame=%d", bounds[[i]], bounds[[i + 1]])
    } else {
      sprintf("trim=start_frame=%d", bounds[[i]])
    }
    demo_render_video(path, output, paste0(trim, ",setpts=PTS-STARTPTS"))
  }
}

first_frame <- function(video, output, time = 0, filter = NULL) {
  status <- system2("ffmpeg", c(
    "-hide_banner", "-loglevel", "error", "-y",
    "-ss", time, "-i", shQuote(video),
    if (!is.null(filter)) c("-vf", shQuote(filter)),
    "-frames:v", "1", shQuote(output)
  ))
  if (!identical(status, 0L)) {
    cli::cli_abort("FFmpeg failed to write {.file {output}}.")
  }
}

# The functions below port the flights clips' `demo-utils.sh`. The source here
# is already constant 60 fps, so clipping trims by frame.

demo_clip_filter <- function(start, end, fps) {
  paste0(
    "trim=start_frame=", round(start * fps), ":end_frame=", round(end * fps), ",",
    "setpts=N/(", fps, "*TB)"
  )
}

demo_freeze_filter <- function(frame, extra_frames, fps) {
  paste0(
    "loop=loop=", extra_frames, ":size=1:start=", frame, ",",
    "setpts=N/(", fps, "*TB)"
  )
}

demo_zoom_filter <- function(
  zoom_in_start, zoom_in_end, zoom_out_start, zoom_out_end,
  max_zoom, top_offset, width, height, fps
) {
  demo_zoom_at_filter(
    zoom_in_start, zoom_in_end, zoom_out_start, zoom_out_end,
    max_zoom, 0, top_offset, width, height, fps
  )
}

demo_zoom_at_filter <- function(
  zoom_in_start, zoom_in_end, zoom_out_start, zoom_out_end,
  max_zoom, left_offset, top_offset, width, height, fps
) {
  zoom_in_frames <- zoom_in_end - zoom_in_start
  zoom_out_frames <- zoom_out_end - zoom_out_start
  paste0(
    "zoompan=z='",
    "if(lt(on,", zoom_in_start, "),1,",
    "if(lte(on,", zoom_in_end, "),1+((", max_zoom, ")-1)/2*(1-cos(PI*(on-", zoom_in_start, ")/", zoom_in_frames, ")),",
    "if(lt(on,", zoom_out_start, "),", max_zoom, ",",
    "if(lte(on,", zoom_out_end, "),", max_zoom, "-((", max_zoom, ")-1)/2*(1-cos(PI*(on-", zoom_out_start, ")/", zoom_out_frames, ")),1))))",
    "':x='iw*", left_offset, "*(zoom-1)/((", max_zoom, ")-1)'",
    ":y='ih*", top_offset, "*(zoom-1)/((", max_zoom, ")-1)'",
    ":d=1:s=", width, "x", height, ":fps=", fps
  )
}

demo_zoom_in_filter <- function(
  zoom_start, zoom_end, max_zoom, left_offset, top_offset, width, height, fps
) {
  zoom_frames <- zoom_end - zoom_start
  paste0(
    "zoompan=z='",
    "if(lt(on,", zoom_start, "),1,",
    "if(lte(on,", zoom_end, "),1+((", max_zoom, ")-1)/2*(1-cos(PI*(on-", zoom_start, ")/", zoom_frames, ")),", max_zoom, "))",
    "':x='iw*", left_offset, "*(zoom-1)/((", max_zoom, ")-1)'",
    ":y='ih*", top_offset, "*(zoom-1)/((", max_zoom, ")-1)'",
    ":d=1:s=", width, "x", height, ":fps=", fps
  )
}

demo_zoom_transition_filter <- function(
  transition_start, transition_end, start_zoom, end_zoom,
  start_left, end_left, start_top, end_top, width, height, fps
) {
  n <- transition_end - transition_start
  ease <- function(from, to) {
    paste0(
      "if(lt(on,", transition_start, "),", from, ",",
      "if(lte(on,", transition_end, "),", from, "+((", to, ")-(", from, "))/2*(1-cos(PI*(on-", transition_start, ")/", n, ")),", to, "))"
    )
  }
  paste0(
    "zoompan=z='", ease(start_zoom, end_zoom), "'",
    ":x='iw*", ease(start_left, end_left), "'",
    ":y='ih*", ease(start_top, end_top), "'",
    ":d=1:s=", width, "x", height, ":fps=", fps
  )
}

# Eases zoom and top-left offsets (fractions of the input size) between
# keyframes, one row per keyframe: frame, zoom, left, top. Like
# `demo_zoom_transition_filter()`, chained.
demo_keyframe_filter <- function(keys, width, height, fps) {
  ease <- function(col) {
    expr <- as.character(keys[nrow(keys), col])
    for (i in rev(seq_len(nrow(keys) - 1))) {
      f0 <- keys[i, 1]
      f1 <- keys[i + 1, 1]
      v0 <- keys[i, col]
      v1 <- keys[i + 1, col]
      expr <- paste0(
        "if(lte(on,", f1, "),", v0, "+((", v1, ")-(", v0, "))/2*(1-cos(PI*(on-", f0, ")/", f1 - f0, ")),", expr, ")"
      )
    }
    paste0("if(lt(on,", keys[1, 1], "),", keys[1, col], ",", expr, ")")
  }
  paste0(
    "zoompan=z='", ease(2), "'",
    ":x='iw*", ease(3), "'",
    ":y='ih*", ease(4), "'",
    ":d=1:s=", width, "x", height, ":fps=", fps
  )
}

demo_render_video <- function(source, output, filter) {
  status <- system2("ffmpeg", c(
    "-hide_banner", "-loglevel", "error", "-y",
    "-i", shQuote(source),
    "-vf", shQuote(filter),
    "-an",
    "-c:v", "libx264",
    "-preset", "slow",
    "-crf", "18",
    "-pix_fmt", "yuv420p",
    "-movflags", "+faststart",
    shQuote(output)
  ))
  if (!identical(status, 0L)) {
    cli::cli_abort("FFmpeg failed to render {.file {output}}.")
  }
}

if (sys.nframe() == 0L) {
  edit_pa_demos()
}
