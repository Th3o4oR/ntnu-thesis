#import "@preview/tiptoe:0.4.0": *

#import "./utils.typ": maybe-sans-serif, months-no, t

#let left-margin = 60mm
#let bar-width = 30mm

#let front-cover(
  title: "Example Title in Primary Language",
  subtitle: "Example Subtitle in Primary Language",
  authors: ("Peter Grey", "Joan Yellow"),
  supervisors: ("Molly Salmon", "Alistair Orange"),
  degree-name: "Example degree name",
  faculty: "Example faculty",
  department: "Example department",
  cycle: 2,
  date: datetime.today(),
  lang: "en",
  bar-color: rgb("#D4C79B"),
  logo: image("../assets/NTNU_logo_liggende_med_visjon.svg", width: 45mm),
  style,
) = page(
  margin: (left: left-margin, right: 30mm, top: 40mm, bottom: 25mm),
  {
    set text(font: maybe-sans-serif(style))

    // --- Left Vertical Banner & Affiliation Sidebar ---
    let thesis-type = if cycle == 1 {
      t("bachelors-thesis")
    } else {
      t("masters-thesis")
    }

    let bar-height = 75mm
    let bar-inset = 5mm

    // Colored ribbon at top-left
    place(
      top + left,
      dx: -left-margin,
      rect(
        width: bar-width,
        height: bar-height,
        fill: bar-color,
        inset: bar-inset,
        align(right + bottom, rotate(-90deg, reflow: true)[
          #text(size: 15pt, weight: "bold", fill: rgb("#000000"), thesis-type)
        ]),
      ),
    )

    // Rotated affiliation block below ribbon
    place(
      top + left,
      dx: -left-margin,
      dy: bar-height + bar-inset,
      rect(
        stroke: none,
        width: bar-width,
        align(top + right, rotate(-90deg, reflow: true)[
          #set text(size: 7.5pt)
          *#t("uni-short")* \
          #t("uni-long") \
          #if faculty != none [ #faculty \ ]
          #if department != none [ #department ]
        ]),
      ),
    )

    // Subtle horizontal divider line
    place(
      top + left,
      dx: -left-margin,
      dy: bar-height * 2 + bar-inset * 3,
      line(
        tip: stealth,
        start: (0mm, 0mm),
        end: (left-margin - bar-width / 3, 0mm),
        stroke: 1pt + rgb("#F1EDE0"),
      ),
    )

    // --- Main Right Column ---
    // Author, title and subtitle
    let author-text = text(
      size: 15pt,
      authors.join(", "),
    )
    let title-text = text(
      size: 22pt,
      weight: "bold",
      title,
    )
    let subtitle-text = if subtitle != none [
      #text(size: 13pt, fill: rgb("#333333"), subtitle)
      #v(1em)
    ]

    [
      #author-text

      #title-text

      #subtitle-text
    ]

    // Necessary as of 2026-08-24 because datetime.display doesn't automatically translate based on the text language.
    // See: https://github.com/typst/typst/issues/2840
    // And: https://github.com/typst/typst/issues/1537
    let formatted-date = if lang == "en" [
      #date.display("[month repr:long] [year]")
    ] else {
      let translated-month(dt) = months-no.at(dt.month() - 1)
      [#translated-month(date) #date.year()]
    }

    let supervisor-label = if supervisors.len() == 1 {
      t("supervisor")
    } else {
      t("supervisors")
    }

    [
      #set text(size: 11pt)
      #thesis-type #t("in") #degree-name \
      #if supervisors != () and supervisors != none [
        #supervisor-label: #supervisors.join(", ") \
      ]
      #formatted-date
    ]

    // Logo at the bottom of the page
    v(1fr)
    if logo != none {
      logo
    }
  },
)

#let back-cover(
  year: 2026,
  style,
) = page(
  margin: (top: 65mm, bottom: 30mm, left: 74pt, right: 35mm),
  {
    set text(size: 12pt, font: maybe-sans-serif(style))

    v(1fr)

    set text(size: 10pt)
    show link: it => text(fill: rgb("#1954A6"), it)

    [
      #set text(size: 8pt)
      #t("trondheim-norway") #year \
      #link("https://www.ntnu.no/", "www.ntnu.no")
    ]
  },
)
