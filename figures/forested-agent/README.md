# Forested agent demos

Records the commons demo against the agent in `forested/` and edits it into the clips used in the slides.

The original commons clips came from one continuous screen recording, edited with FFmpeg holds and zooms (`~/Desktop/commons-demo-new/*.sh`), then split at fixed points. These scripts do the same: `record-demos.R` records one three-turn conversation, and `edit-demos.R` applies the original holds, zoom depths, zoom offsets, and split points.

From the talk repository root, start the app:

```sh
Rscript -e 'shiny::runApp("forested", port = 8765, launch.browser = FALSE)'
```

Then, in another terminal:

```sh
Rscript figures/forested-agent/record-demos.R
Rscript figures/forested-agent/edit-demos.R
```

`record-demos.R` writes `figures/raw/forested-agent-raw.mp4` and a log of event times, `figures/raw/forested-agent-events.json`. `edit-demos.R` anchors each effect to those events, since responses stream at a different pace each take.

| Clip | Turn | Edited like |
|---|---|---|
| `commons-01-forest-share` (`-a` to `-d`) | What percentage of Washington is forested? | `commons-01-traffic-trend` |
| `commons-02-column-mean` (`-a`, `-b`) | Isn't the mean of the whole column different? | `commons-03-most-visits` |
| `commons-03-official-gap` (`-a`, `-b`) | Why is that different from the official number? | `commons-02-page-views` |
