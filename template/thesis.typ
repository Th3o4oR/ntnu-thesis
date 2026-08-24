#import "@preview/ntnu-thesis:0.2.0": ntnu-thesis, setup-appendices

// The template is extensible and plays well with other dependencies;
// For example, a table of acronyms can be generated using glossarium
#import "@preview/glossarium:0.5.10": make-glossary, print-glossary, register-glossary
#import "./acronyms.typ": acronyms
#show: make-glossary
#register-glossary(acronyms)

// Configure formatting options before invoking the template;
// For example, uncomment below to set another font (except for covers)
// #set text(font: "New Computer Modern")

// --------------------------------------------------------------------- //
// ---------- MAIN THESIS TEMPLATE ENTRYPOINT & CONFIGURATION ---------- //
// --------------------------------------------------------------------- //
#show: ntnu-thesis.with(
  // Primary document language; either "en" or "no"
  primary-lang: "no",
  // Language-specific title, subtitle, abstract, and keywords.
  // Grouped by language, with only values for "en" and "no" being mandatory.
  // Localized abstract/keywords headings may be omitted only for "en" and "no".
  // Field "alpha-3" is the language's ISO 639-3 code, for non-"en"/"no" langs.
  // If desired, any "subtitle" field may be set to none (to omit it entirely).
  localized-info: (
    en: (
      title: "How to Abandon Dinosaur-Age TypeSetting Software",
      subtitle: "A Modern Approach to Problem-Solving",
      abstract: include "./content/abstract-1-en.typ",
      keywords: ("Dogs", "Chicken nuggets"),
    ),
    no: (
      title: "Utfasing av typesettingssystemer fra dinosaurenes tid",
      subtitle: "En moderne tilnærming til problemet",
      abstract: lorem(300),
      keywords: ("Hunder", "Kyllingnuggets"),
    ),
    pt: (
      alpha-3: "por",
      title: "Tradução em Português do Título",
      subtitle: "Tradução em Português do Subtítulo",
      abstract-heading: "Resumo",
      keywords-heading: "Palavras-chave",
      abstract: include "./content/abstract-3-pt.typ",
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
    code: "MTTK",
    name: "Kybernetikk og Robotikk",
    kind: "Master of Science",
    cycle: 2,
  ),
  // Faculty that the thesis is part of (abbreviation)
  faculty: "EECS",
  // Optional image to show on the front cover.
  // This should either be missing, or an "image" element. For example,
  // cover-image: image("./assets/cover.png", width: 100%)
  // If provided, the image can be formatted arbitrarily to look however desired
  // (especially its height, width, and fit mode). However, the recommended
  // styles are (width: 100%) or (width: 16cm, height: 10cm, fit: "contain").
  cover-image: none,
  // Optional colour override for the front of the cover.
  cover-color: none,
  // Acknowledgements body
  acknowledgements: include "content/acknowledgements.typ",
  // Additional front-matter sections, each with keys "heading" and "body"
  extra-preambles: (
    (heading: "Acronyms and Abbreviations", body: print-glossary(acronyms)),
  ),
  // Document date; hardcode for determinism/reproducibility
  doc-date: datetime.today(),
  // Document city (where it's being signed/authored/submitted)
  doc-city: "Trondheim",
  // Extra keywords, embedded in document metadata but not listed in text
  doc-extra-keywords: ("master thesis",),
  // Miscellaneous settings affecting the document's appearance
  style: (
    // Whether the proprietary Arial font should be used in Sans-Serif contexts.
    // While this is the font prescribed by the official KTH covers, it is often
    // preferable to use an open, metric-compatible alternative. If this is set
    // to `false`, Liberation Sans will be used instead of Arial. Otherwise, if
    // this is set to `true`, Typst will issue a warning if Arial is not found
    // on the system at compile-time.
    // Graceful font fallback is not possible until issue typst#6010 is fixed.
    use-arial: false,
    // Whether front matter, headings, and headings should use a Sans-Serif font
    more-sans-serif: false,
    // Whether to make top-level headings stand out more and look less plain
    fancy-chapters: false,
  ),
)

// Tip: when tagging elements, scope labels like <intro:goals:example>

#include "./content/ch01-introduction.typ"
#include "./content/ch02-background.typ"
#include "./content/ch03-method.typ"
#include "./content/ch04-the-thing.typ"
#include "./content/ch05-results.typ"
#include "./content/ch06-discussion.typ"
#include "./content/ch07-conclusion.typ"

#bibliography("references.yaml", title: "References")

#show: setup-appendices
#include "./content/zz-a-usage.typ"
#include "./content/zz-b-else.typ"
