#import "@preview/physica:0.9.5": *

#import "@preview/fancy-units:0.1.1": num, unit, qty, fancy-units-configure, add-macros
#let CUSTOM_UNITS = (
    msol: [M#sub[#sym.dot.circle]]
)

#let FONT = "New Computer Modern" // default LaTeX font
#let CITATION_STYLE = "chicago-author-date"

// Define title command:
#let title(titlestring) = {
    set align(center)
    text(2.5em,weight:"bold",box[#align(center)[#titlestring]])
    set document(title:titlestring)
    v(1em)
}
// Define author command:
#let author(authorstring) = {
    set align(center)
    v(-2em)
    text(1.8em,weight:"medium",box[#align(center)[#authorstring]])
    set document(author:authorstring)
    v(1em)
}

// Define preferred table command:
#let tab(labelstring, caption, columns, ..content) = [
    #figure(
        table(
            columns: columns,
            ..content
        ),
        caption: caption
    ) #label("tab:"+labelstring)
]

// Define preferred figure command: // TODO: This has been temporarily solved with passing an image object, because currently packages can only load files from their package root directory, see at the end of https://typst.app/docs/reference/syntax/#paths under "paths and packages"
// #let fig(filename, caption) = [
//     #figure(
//         image("/assets/"+filename+".png"),
//         caption: caption
//     ) #label("fig:"+filename)
// ]
#let fig(imageobject, filename, caption) = [
    #figure(
        imageobject,
        caption: caption
    ) #label("fig:"+filename)
]


// Define todo function (source: https://github.com/typst/typst/issues/662#issuecomment-1516709607)
#let todo(x) = [ #text([TODO: #[#x <todo>]], red) ]
#let todos() = {
    locate(loc => {
        let elems = query(
            <todo>,
            loc,
        )
        if elems.len() == 0 {
            return
        }
        [= TODOs]
        for body in elems {
            text([+ #link(body.location(), body.text)], red) 
        }
    })
}


// template
#let eekhof(doc) = [
    #fancy-units-configure(
        uncertainty-mode: "plus-minus", // use "conserve" to retain braces or +-
        per-mode: "fraction"
    )
    #add-macros(..CUSTOM_UNITS)

    // // Very visible links for cases where it needs to be clear to users that something can be clicked:
    // #show link: it => {
    //   if type(it.dest) == str {
    //     text(fill: rgb("#0059a6"))[#it#super[#text(weight: "thin")[↑]]]
    //   } else {
    //     text(fill: rgb("#0059a6"))[super[#text(weight: "thin")[↓]](it.body))]
    //   }
    // }
    // External links: blue + underlined. Internal links: default.
    #show link: it => {
      if type(it.dest) == str {
        underline(text(fill: blue)[#it])
      } else {
        it
      }
    }

    #set page(numbering: "1", margin:8.0%)
    #set text(font: FONT)
    #set par(justify: true)

    #set heading(numbering: "1.")
    // TODO: Increase padding around headings?
    // #show heading: it => [
    //     #set par(leading: 4em, spacing: 1em)
    //     #it.body
    // ]

    #set table(
        stroke: (x, y) => (
            top: if y <= 1 { 0.065em } else { 0em },
            bottom: 0.065em
        ),
        align: center + horizon
    )
    #show table.cell.where(y: 0): set text(weight: "bold")

    #set bibliography(style: CITATION_STYLE)

    // Make @ references hold and not print comments in the [] for page reference (Source see https://forum.typst.app/t/how-to-overwrite-built-in-functions/4998/5): (This is left out in favor of inline comments after the cite command)
    // #show std.cite: it => {
    //     if it.supplement == none { return it }
    //     std.cite(it.key, supplement: none, form: it.form, style: it.style)
    // }

    #doc

]
// incfig to automatically load from assets folder, label and center



// Helper function to print out typst internal variable names as raw text:
#let toraw(value) = [
    #raw(repr(value).slice(1,-1))
]
#let help() = [
    = Eekhof package documentation
    == Usage
        To make use of all the packages settings and features, load the package and its template with
        ```
        #import "@local/eekhof:0.1.0": *
        #show: eekhof
        ```
    == Commands available
        === From packages
            ==== Fancy-Units
                Use
                ```
                #qty[0.9(1)][kg m^2 /s]
                #num[0.6 +- 0.2]
                #unit[M_#sym.dot.circle]
                ```
                Custom defined units:
                #for (key, value) in CUSTOM_UNITS.keys().zip(CUSTOM_UNITS.values()) [
                    - #toraw(key) = #unit[#value]
                ]
            ==== Physica
              Useful maths commands, such as
              ```
              #pdv(,x,y,[2,3]) f (x)
              #curl
              #grad
              ```
              For more see https://github.com/Leedehai/typst-physics/blob/v0.9.5/physica-manual.pdf
        === Custom commands
            The following custom commands have been defined:
            - `#title("title string")` for styling a string as a title of the document
            - `#author("author string")` for styling a string as the author of a document
            - `#todo("description")` for highlighting text in the document as todo and print it with `#todos()`
            - `#todos()` for printing a list of all todos set with `#todo()` in the document
            - `#tab("label string", "caption", n_columns, [content1], [content2], ...)` to include a table that is formatted according to @eekhof_style_choices and centered in a figure environment with a label associated with it as "tab:labelstring"
            - `#fig(image("imagepath"), "imagelabel", "caption")` to include a figure with a caption and a label associated with it as "fig:imagelabel"

    == Style choices made <eekhof_style_choices>
        === General
            The font is set to #toraw(FONT). The default latex fonta is `New Computer Modern`. Paragraphs are justified and the sections are numbered with decimals and points.

            Page numbers have been added to the footer of the page.

            The citation style is set to #toraw(CITATION_STYLE).

            Tables have bold font in their upper row, which is bounded by two lines of `0.65em` thickness, and one of the same thickness below the table. All the contents of the cells are centered in the cells.

        === Fancy-Units
            The `uncertainty-mode` has been set to `plus-minus`, use `conserve` to be able to use braces.

            The `per-mode` has been set to `fraction`.


    == Best practices with this package
        When writing a citation like `@einstein1920`, write notes on where exactly the information relevant to the case at hand is found in the document as inline comments, like `@einstein1920/*p. 230, sec. 3.1*/`

]
