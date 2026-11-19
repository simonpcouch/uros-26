# Posit Assistant forested demo

Edits the forested Posit Assistant screen recording into the clips used in the slides, with the same holds, zoom depths, zoom offsets, and split points as the flights clips (`~/Desktop/posit-assistant-demo-new/*.sh`, split in conf-26).

The raw recording is `figures/forested-demo.mov`. Compress it, then render from the talk repository root:

```sh
ffmpeg -i figures/forested-demo.mov -vf fps=60 -an -c:v libx264 -preset slow \
  -crf 28 -pix_fmt yuv420p -movflags +faststart \
  figures/raw/forested-pa-demo-compressed.mp4
Rscript figures/forested-pa/edit-demos.R
```

Effects are anchored to event times in `pa_events()`, measured from frame differences, with the matching flights times noted next to each.

| Clip | Edited like |
|---|---|
| `pa-01-webfetch` (`-a`, `-b`, full window, first frame) | `01-pa-demo-webfetch` |
| `pa-02-docs` (`-a`, `-b`) | `02-pa-demo-docs` |
| `pa-03-clean-data` (`-a` to `-d`) | `03-pa-demo-clean-data` |
| `pa-05-plot` (`-a` to `-c`) | `05-pa-demo-carriers` |
| `pa-06-report` | `06-pa-demo-report` |
| `pa-08-model-cost` | `08-pa-demo-model-cost` |

Unsplit renders go to `figures/raw/`.
