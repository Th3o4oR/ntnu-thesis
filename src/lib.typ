#import "./covers.typ": *
#import "./front-matter.typ": *
#import "./styling-setup.typ": *
#import "./utils.typ": (
  assert-arg-type, extract-name, get-one-liner, maybe-sans-serif, z, z-arbitrarily-keyed-dict, z-matches-regex,
)

#let ntnu-thesis(
  // Primary document language; either "en" or "no"
  primary-lang: "en",
  // Language-specific title, subtitle, abstract, and keywords.
  // Grouped by language, with only values for "en" and "no" being mandatory.
  // Localized abstract/keywords headings may be omitted only for "en" and "no".
  // Field "alpha-3" is the language's ISO 639-3 code, for non-"en"/"no" langs.
  // If desired, any "subtitle" field may be set to none (to omit it entirely).
  localized-info: (
    en: (
      title: "English title",
      subtitle: "English subtitle",
      abstract: lorem(300),
      keywords: ("Dogs", "Chicken nuggets"),
    ),
    no: (
      title: "Norsk oversettelse av tittelen",
      subtitle: "Norsk oversettelse av undertittelen",
      abstract: lorem(300),
      keywords: ("Hunder", "Kyllingnuggets"),
    ),
    pt: (
      alpha-3: "por",
      title: "Tradução em Português do Título",
      subtitle: "Tradução em Português do Subtítulo",
      abstract-heading: "Resumo",
      keywords-heading: "Palavras-chave",
      abstract: lorem(300),
      keywords: ("Cães", "Nuggets de frango"),
    ),
  ),
  // Ordered author information; only first and last names fields are mandatory
  authors: (
    (
      first-name: "John",
      last-names: "Doe",
      email: "john.doe@example.com",
      user-id: "jod",
      faculty: "Faculty of Information Technology and Electrical Engineering",
      department: "Department of Typesetting Sanity",
    ),
    (
      first-name: "Jane",
      last-names: "Doe",
    ),
  ),
  // Ordered supervisor information; "external-org" replaces userid/faculty/dept
  supervisors: (
    (
      first-name: "Alice",
      last-names: "Smith",
      email: "alice@example.com",
      user-id: "alice",
      faculty: "Faculty of Information Technology and Electrical Engineering",
      department: "Department of Loyal Supervision",
    ),
    (
      first-name: "Bob",
      last-names: "Jones",
      email: "bob@example.com",
      external-org: "Selskap AS",
    ),
  ),
  // Degree as part of which the thesis is conducted; all fields are mandatory.
  // Kind is the degree title conferred as listed in the third dropdown above.
  // Cycle is either 1 (Bachelor's) or 2 (Master's), per Bologna.
  degree: (
    code: "TCYSM",
    name: "Master's Program, Cybersecurity",
    kind: "Master of Science",
    cycle: 2,
  ),
  // Faculty that the thesis is part of (abbreviation)
  faculty: "EECS",
  // Optional image to show on the front cover.
  // This should either be none, or an "image" element. For example,
  // cover-image: image("./assets/cover.png", width: 100%)
  // If provided, the image can be formatted arbitrarily to look however desired
  // (especially its height, width, and fit mode). However, the recommended
  // styles are (width: 100%) or (width: 16cm, height: 10cm, fit: "contain").
  cover-image: none,
  // Acknowledgements body
  acknowledgements: {
    par(lorem(100))
    par(lorem(150))
  },
  // Additional front-matter sections, each with keys "heading" and "body".
  // For example, ((heading: "Acronyms and Abbreviations", body: glossary),)
  extra-preambles: (),
  // Document date; hardcode for determinism/reproducibility
  doc-date: datetime.today(),
  // Document city (where it's being signed/authored/submitted)
  doc-city: "Trondheim",
  // Extra keywords, embedded in document metadata but not listed in text
  doc-extra-keywords: ("master thesis",),
  // Miscellaneous settings affecting the document's appearance
  style: (:),
  // Document body
  body,
) = context {
  // manual type checking because typst sadly has no strong typing and sometimes
  // incorrect arguments can lead to very strange errors that are hard to debug
  // (especially when accidentally using `(x)` instead of `(x,)` to construct an
  // array, leading to no array being constructed at all)
  // note that this is not necessarily exhaustive and is intended just as a
  // convenience, so that obvious problems surface immediately and clearly

  assert-arg-type("primary-lang", primary-lang, z.choice(("en", "no")))
  assert-arg-type("localized-info", localized-info, z-arbitrarily-keyed-dict(
    "localized-info",
    z.string(assertions: (z.assert.length.equals(2),)),
    z.dictionary(
      (
        alpha-3: z.string(optional: true, assertions: (
          z.assert.length.equals(3),
        )),
        title: z.string(min: 1),
        subtitle: z.string(optional: true, min: 1),
        abstract: z.content(),
        keywords: z.array(z.string(min: 1)),
      ),
    ),
    min: 1,
    require-keys: ("en", "no"),
  ))
  assert-arg-type("authors", authors, z.array(
    z.dictionary((
      first-name: z.string(min: 1),
      last-names: z.string(min: 1),
      email: z.email(optional: true),
      user-id: z.string(optional: true, min: 1),
      faculty: z.string(optional: true, min: 1),
      department: z.string(optional: true, min: 1),
    )),
    min: 1,
  ))
  let internal-person = z.dictionary((
    first-name: z.string(min: 1),
    last-names: z.string(min: 1),
    email: z.email(),
    user-id: z.string(min: 1),
    faculty: z.string(min: 1),
    department: z.string(min: 1),
  ))
  assert-arg-type("supervisors", supervisors, z.array(
    z.either(internal-person, z.dictionary((
      first-name: z.string(min: 1),
      last-names: z.string(min: 1),
      email: z.email(),
      external-org: z.string(min: 1),
    ))),
    min: 1,
  ))
  assert-arg-type("degree", degree, z.dictionary((
    code: z.string(min: 1),
    name: z.string(min: 1),
    kind: z.string(min: 1),
    cycle: z.number(min: 1, max: 2), // better error messages than z.choice
  )))
  assert-arg-type("faculty", faculty, z.choice((
    "ABE",
    "EECS",
    "ITM",
    "CBH",
    "SCI",
  )))
  assert-arg-type("cover-image", cover-image, z.content(optional: true))
  assert-arg-type(
    "acknowledgements",
    acknowledgements,
    z.content(optional: true),
  )
  assert-arg-type("extra-preambles", extra-preambles, z.array(z.dictionary((
    heading: z.string(min: 1),
    body: z.content(),
  ))))
  assert-arg-type("doc-date", doc-date, z.date())
  assert-arg-type("doc-city", doc-city, z.string(min: 1))
  assert-arg-type("doc-extra-keywords", doc-extra-keywords, z.array(
    z.string(min: 1),
  ))
  assert-arg-type("style", style, z.dictionary(
    (
      use-arial: z.boolean(optional: true),
      more-sans-serif: z.boolean(optional: true),
      fancy-chapters: z.boolean(optional: true),
    ),
    optional: true,
  ))

  // ---------- END OF MANUAL TYPE CHECKING ----------

  let style = (
    (
      more-sans-serif: false,
      use-arial: false,
      fancy-chapters: false,
    )
      + style // provided values have higher precedence over default values
  )

  let alt-lang = if primary-lang == "en" {
    "no"
  } else if primary-lang == "no" {
    "en"
  } else {
    panic("Invalid primary language " + primary-lang)
  }

  let primary-info = localized-info.at(primary-lang)
  let alt-info = localized-info.at(alt-lang)

  let author-names = authors.map(extract-name)
  let supervisor-names = supervisors.map(extract-name)

  set document(
    title: get-one-liner(primary-lang, primary-info),
    description: get-one-liner(alt-lang, alt-info), // Subject field
    date: doc-date,
    keywords: primary-info.at("keywords") + doc-extra-keywords,
    author: author-names,
  )
  set page("a4")
  set text(lang: primary-lang, size: 12pt)

  front-cover(
    title: primary-info.title,
    subtitle: primary-info.at("subtitle", default: none),
    authors: author-names,
    supervisors: supervisor-names,
    degree-name: degree.name,
    faculty: authors.at(0).faculty,
    department: authors.at(0).department,
    cycle: degree.cycle,
    date: doc-date,
    lang: primary-lang,
    style,
  )

  page[] // blank

  set text(font: maybe-sans-serif(style))

  title-page(
    title: primary-info.title,
    subtitle: primary-info.at("subtitle", default: none),
    authors: author-names,
    supervisors: supervisor-names,
    degree-name: degree.name,
    faculty: authors.at(0).faculty,
    department: authors.at(0).department,
    cycle: degree.cycle,
    date: doc-date,
    lang: primary-lang,
    style,
  )

  copyright-page(year: doc-date.year(), authors: author-names)

  global-setup(style, {
    set page(numbering: "i")
    counter(page).update(1)

    for (lang, info) in localized-info {
      page(
        localized-abstract(
          lang: lang,
          abstract-heading: info.at("abstract-heading", default: none),
          keywords-heading: info.at("keywords-heading", default: none),
          keywords: info.at("keywords"),
          info.at("abstract"),
        ),
      )
      page(header: none, footer: none, []) // blank
    }

    page(
      signed-acknowledgements(
        city: doc-city,
        date: doc-date,
        authors: author-names,
        acknowledgements,
      ),
    )

    page(indices)

    for extra in extra-preambles {
      extra-preamble(title: extra.at("heading"), extra.at("body"))
    }

    [#metadata(()) <front-matter-end>]
    pagebreak(to: "odd")

    // text.font reflects original font because of the `context` surrounding
    // this entire function (prior to when the font was changed)
    set text(font: text.font)

    set page(numbering: "1")
    counter(page).update(1)

    styled-body(style, body)
  })

  [#metadata(()) <content-end>]
  pagebreak(to: "odd")

  page[] // empty
  back-cover(
    year: doc-date.year(),
    style,
  )
}
