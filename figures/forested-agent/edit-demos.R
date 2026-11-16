# Cuts the raw forested recording into the commons demo clips, using the same
# holds, zoom depths, zoom offsets, and split points as the original commons
# clips (see `~/Desktop/commons-demo-new/*.sh` and conf-26's "split commons
# demo videos" commit). Effect timings are anchored to logged events, since
# the new responses stream at a different pace than the original ones.
edit_forested_demos <- function(
  raw = "figures/raw/forested-agent-raw.mp4",
  events = "figures/raw/forested-agent-events.json",
  output_dir = "figures"
) {
  ev <- jsonlite::read_json(events, simplify_vector = TRUE)
  # The popup is open within a frame or two of the cursor reaching the marker.
  popup <- function(turn) ev[[paste0(turn, "_hover")]] + 0.1

  clips <- list(
    # Trusted calculation, edited like commons-01-traffic-trend.
    list(
      name = "commons-01-forest-share",
      start = ev$turn1_prompt_done - 1,
      end = popup("turn1"),
      prompt = ev$turn1_prompt_done,
      prompt_hold = 30,
      popup_hold = 108,
      zoom_in = 120,
      zoom_in_frames = 48,
      pan = ev$turn1_answer_start - 0.4,
      pan_frames = 48,
      partial_out = popup("turn1") - 1.5,
      partial_out_frames = 60,
      full_out_after_popup = 60,
      full_out_frames = 48,
      max_zoom = 1.5,
      partial_zoom = 1.25,
      offsets = c(0, 0.187, 0.2),
      splits = function(f) c(f$pan - 3, f$partial_out + 6, f$popup + 40)
    ),
    # Untrusted answer, edited like commons-03-most-visits.
    list(
      name = "commons-02-column-mean",
      start = ev$turn2_type_start - 0.1,
      end = popup("turn2"),
      prompt = ev$turn2_prompt_done,
      prompt_hold = 30,
      popup_hold = 60,
      zoom_in = 30,
      zoom_in_frames = 48,
      pan = NULL,
      pan_frames = 48,
      partial_out = ev$turn2_answer_start - 0.2,
      partial_out_frames = 48,
      # Like the original, this clip keeps its final zoom.
      full_out_after_popup = NULL,
      full_out_frames = 48,
      max_zoom = 1.8,
      partial_zoom = 1.5,
      offsets = c(0.444444, 0.444444, 0.333333),
      splits = function(f) f$popup - 98
    ),
    # Cited answer, edited like commons-02-page-views.
    list(
      name = "commons-03-official-gap",
      start = ev$turn3_type_start - 0.1,
      end = popup("turn3"),
      prompt = ev$turn3_prompt_done,
      prompt_hold = 30,
      popup_hold = 108,
      zoom_in = 30,
      zoom_in_frames = 48,
      pan = NULL,
      pan_frames = 48,
      partial_out = ev$turn3_answer_start - 0.55,
      partial_out_frames = 66,
      full_out_after_popup = 60,
      full_out_frames = 48,
      max_zoom = 1.5,
      partial_zoom = 1.35,
      offsets = c(0.333333, 0.333333, 0.177),
      splits = function(f) f$popup - 50
    )
  )

  for (clip in clips) {
    render_clip(clip, raw, output_dir)
  }
  first_frame(
    file.path(output_dir, "commons-01-forest-share.mp4"),
    file.path(output_dir, "commons-01-forest-share-first-frame.png")
  )
  invisible()
}

render_clip <- function(clip, raw, output_dir, fps = 60) {
  frames <- clip_frames(clip, fps)
  filter <- paste(
    demo_clip_filter(clip$start, clip$end, fps),
    demo_freeze_filter(frames$prompt, clip$prompt_hold, fps),
    demo_freeze_filter(frames$popup, clip$popup_hold, fps),
    demo_staged_zoom_filter(
      frames$zoom_in, frames$zoom_in + clip$zoom_in_frames,
      frames$pan, frames$pan + clip$pan_frames,
      frames$partial_out, frames$partial_out + clip$partial_out_frames,
      frames$full_out, frames$full_out + clip$full_out_frames,
      clip$max_zoom, clip$partial_zoom,
      clip$offsets[[1]], clip$offsets[[2]], clip$offsets[[3]],
      3340, 1874, fps
    ),
    sep = ","
  )
  output <- file.path(output_dir, paste0(clip$name, ".mp4"))
  demo_render_video(raw, output, filter)

  cuts <- clip$splits(frames)
  split_video(output, cuts, fps)
  cli::cli_inform(c(
    "Rendered {.file {output}}.",
    " " = "Frames: {paste(names(frames), unlist(frames), sep = ' = ', collapse = ', ')}.",
    " " = "Splits at output frames {cuts}."
  ))
}

# Converts event times into output frames. Holds insert frames, so effects
# after a hold shift by its length, as in the original scripts.
clip_frames <- function(clip, fps) {
  to_frame <- function(time) round((time - clip$start) * fps)
  prompt <- to_frame(clip$prompt)
  after_prompt <- function(time) to_frame(time) + clip$prompt_hold
  popup <- after_prompt(clip$end)
  partial_out <- after_prompt(clip$partial_out)
  pan <- if (is.null(clip$pan)) {
    # The pan is a no-op when the first two offsets match; place it just
    # before the partial zoom-out so the expressions stay ordered.
    partial_out - clip$pan_frames - 1
  } else {
    after_prompt(clip$pan)
  }
  full_out <- if (is.null(clip$full_out_after_popup)) {
    popup + clip$popup_hold + 1000
  } else {
    popup + clip$full_out_after_popup
  }
  list(
    prompt = prompt,
    zoom_in = clip$zoom_in,
    pan = pan,
    partial_out = partial_out,
    popup = popup,
    full_out = full_out
  )
}

split_video <- function(path, cuts, fps) {
  bounds <- c(0, cuts, Inf)
  for (i in seq_len(length(bounds) - 1)) {
    output <- sub("\\.mp4$", paste0("-", letters[[i]], ".mp4"), path)
    trim <- if (is.finite(bounds[[i + 1]])) {
      sprintf("trim=start_frame=%d:end_frame=%d", bounds[[i]], bounds[[i + 1]])
    } else {
      sprintf("trim=start_frame=%d", bounds[[i]])
    }
    demo_render_video(path, output, paste0(trim, ",setpts=PTS-STARTPTS"))
  }
}

first_frame <- function(video, output) {
  status <- system2("ffmpeg", c(
    "-hide_banner", "-loglevel", "error", "-y",
    "-i", shQuote(video), "-frames:v", "1", shQuote(output)
  ))
  if (!identical(status, 0L)) {
    cli::cli_abort("FFmpeg failed to write {.file {output}}.")
  }
}

# The functions below port `demo-utils.sh` from the original clips verbatim.

demo_clip_filter <- function(start, end, fps) {
  paste0(
    "trim=start=", start, ":end=", end, ",",
    "setpts=PTS-STARTPTS,",
    "fps=", fps, ",setpts=N/(", fps, "*TB)"
  )
}

demo_freeze_filter <- function(frame, extra_frames, fps) {
  paste0(
    "loop=loop=", extra_frames, ":size=1:start=", frame, ",",
    "setpts=N/(", fps, "*TB)"
  )
}

demo_staged_zoom_filter <- function(
  zoom_in_start, zoom_in_end,
  pan_start, pan_end,
  partial_out_start, partial_out_end,
  full_out_start, full_out_end,
  max_zoom, partial_zoom,
  initial_offset, pan_offset, partial_offset,
  width, height, fps
) {
  zoom_in_frames <- zoom_in_end - zoom_in_start
  pan_frames <- pan_end - pan_start
  partial_out_frames <- partial_out_end - partial_out_start
  full_out_frames <- full_out_end - full_out_start

  paste0(
    "zoompan=z='",
    "if(lt(on,", zoom_in_start, "),1,",
    "if(lte(on,", zoom_in_end, "),1+((", max_zoom, ")-1)/2*(1-cos(PI*(on-", zoom_in_start, ")/", zoom_in_frames, ")),",
    "if(lt(on,", partial_out_start, "),", max_zoom, ",",
    "if(lte(on,", partial_out_end, "),", max_zoom, "-((", max_zoom, ")-(", partial_zoom, "))/2*(1-cos(PI*(on-", partial_out_start, ")/", partial_out_frames, ")),",
    "if(lt(on,", full_out_start, "),", partial_zoom, ",",
    "if(lte(on,", full_out_end, "),", partial_zoom, "-((", partial_zoom, ")-1)/2*(1-cos(PI*(on-", full_out_start, ")/", full_out_frames, ")),1))))))",
    "':x='(iw-iw/zoom)/2'",
    ":y='if(lt(on,", pan_start, "),ih*", initial_offset, "*(zoom-1)/((", max_zoom, ")-1),",
    "if(lte(on,", pan_end, "),ih*", initial_offset, "+ih*((", pan_offset, ")-(", initial_offset, "))/2*(1-cos(PI*(on-", pan_start, ")/", pan_frames, ")),",
    "if(lt(on,", partial_out_start, "),ih*", pan_offset, ",",
    "if(lte(on,", partial_out_end, "),ih*", pan_offset, "+ih*((", partial_offset, ")-(", pan_offset, "))/2*(1-cos(PI*(on-", partial_out_start, ")/", partial_out_frames, ")),",
    "if(lt(on,", full_out_start, "),ih*", partial_offset, ",",
    "if(lte(on,", full_out_end, "),ih*", partial_offset, "*(1-1/zoom)/(1-1/", partial_zoom, "),0))))))'",
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
  edit_forested_demos()
}
