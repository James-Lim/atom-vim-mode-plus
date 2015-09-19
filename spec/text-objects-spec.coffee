# Refactoring status: 80%
{getVimState} = require './spec-helper'

describe "TextObject", ->
  [set, ensure, keystroke, editor, editorElement, vimState] = []

  beforeEach ->
    getVimState (_vimState, vim) ->
      vimState = _vimState
      {editor, editorElement} = vimState
      vimState.activateNormalMode()
      vimState.resetNormalMode()
      {set, ensure, keystroke} = vim

  describe "the 'iw' text object", ->
    beforeEach ->
      set
        text: "12345 abcde ABCDE"
        cursor: [0, 9]

    it "applies operators inside the current word in operator-pending mode", ->
      ensure 'diw',
        text:     "12345  ABCDE"
        cursor:   [0, 6]
        register: 'abcde'
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

    it "selects inside the current word in visual mode", ->
      ensure 'viw',
        selectedScreenRange: [[0, 6], [0, 11]]

    it "works with multiple cursors", ->
      set
        addCursor: [0, 1]
      ensure 'viw',
        selectedBufferRange: [
          [[0, 6], [0, 11]]
          [[0, 0], [0, 5]]
        ]

  describe "the 'iW' text object", ->
    beforeEach ->
      set
        text: "12(45 ab'de ABCDE"
        cursor: [0, 9]

    it "applies operators inside the current whole word in operator-pending mode", ->
      ensure 'diW',
        text:     "12(45  ABCDE"
        cursor:   [0, 6]
        register: "ab'de"

    it "selects inside the current whole word in visual mode", ->
      ensure 'viW',
        selectedScreenRange: [[0, 6], [0, 11]]

  describe "the 'i(' text object", ->
    beforeEach ->
      set
        text: "( something in here and in (here) )"
        cursor: [0, 9]

    it "applies operators inside the current word in operator-pending mode", ->
      ensure 'di(',
        text: "()"
        cursor: [0, 1]

    it "applies operators inside the current word in operator-pending mode (second test)", ->
      set
        cursor: [0, 29]
      ensure 'di(',
        text: "( something in here and in () )"
        cursor: [0, 28]

    it "select inner () by skipping nesting pair", ->
      set
        text: 'expect(editor.getScrollTop())'
        cursor: [0, 7]
      ensure 'vi(', selectedText: 'editor.getScrollTop()'

    it "skip escaped pair case-1", ->
      set text: 'expect(editor.g\\(etScrollTp())', cursor: [0, 7]
      ensure 'vi(', selectedText: 'editor.g\\(etScrollTp()'

    it "skip escaped pair case-2", ->
      set text: 'expect(editor.getSc\\)rollTp())', cursor: [0, 7]
      ensure 'vi(', selectedText: 'editor.getSc\\)rollTp()'

    it "skip escaped pair case-3", ->
      set text: 'expect(editor.ge\\(tSc\\)rollTp())', cursor: [0, 7]
      ensure 'vi(', selectedText: 'editor.ge\\(tSc\\)rollTp()'

    it "works with multiple cursors", ->
      set
        text: "( a b ) cde ( f g h ) ijk"
        cursor: [0, 2]
        addCursor: [0, 18]
      ensure 'vi(',
        selectedBufferRange: [
          [[0, 1],  [0, 6]]
          [[0, 13], [0, 20]]
        ]

  describe "the 'i{' text object", ->
    beforeEach ->
      set
        text: "{ something in here and in {here} }"
        cursor: [0, 9]

    it "applies operators inside the current word in operator-pending mode", ->
      ensure 'di{',
        text: "{}"
        cursor: [0, 1]

    it "applies operators inside the current word in operator-pending mode (second test)", ->
      set
        cursor: [0, 29]
      ensure 'di{',
        text: "{ something in here and in {} }"
        cursor: [0, 28]

  describe "the 'i<' text object", ->
    beforeEach ->
      set
        text: "< something in here and in <here> >"
        cursor: [0, 9]

    it "applies operators inside the current word in operator-pending mode", ->
      ensure 'di<',
        text: "<>"
        cursor: [0, 1]

    it "applies operators inside the current word in operator-pending mode (second test)", ->
      set cursor: [0, 29]
      ensure 'di<',
        text: "< something in here and in <> >"
        cursor: [0, 28]

  describe "the 'it' text object", ->
    beforeEach ->
      set
        text: "<something>here</something><again>"
        cursor: [0, 5]

    # [FIXME] original official vim-mode support this, but its also affect other
    # TextObject like i( I don't like original behavior.
    # So I disabled, but for HTML tags, there is some space to improve.
    xit "applies only if in the value of a tag", ->
      ensure 'dit',
        text: "<something></something><again>"
        cursor: [0, 11]

    it "applies operators inside the current word in operator-pending mode", ->
      set cursor: [0, 13]
      ensure 'dit',
        text: "<something></something><again>"
        cursor: [0, 11]

  describe "the 'ip' text object", ->
    beforeEach ->
      set
        text: "\nParagraph-1\nParagraph-1\nParagraph-1\n\n"
        cursor: [2, 2]

    it "applies operators inside the current paragraph in operator-pending mode", ->
      ensure 'yip',
        text: "\nParagraph-1\nParagraph-1\nParagraph-1\n\n"
        cursor: [1, 0]
        register: "Paragraph-1\nParagraph-1\nParagraph-1\n"

    it "selects inside the current paragraph in visual mode", ->
      ensure 'vip',
        selectedScreenRange: [[1, 0], [4, 0]]

  describe "the 'ap' text object", ->
    beforeEach ->
      set
        text: "text\n\nParagraph-1\nParagraph-1\nParagraph-1\n\nmoretext"
        cursor: [3, 2]

    it "applies operators around the current paragraph in operator-pending mode", ->
      ensure 'yap',
        text: "text\n\nParagraph-1\nParagraph-1\nParagraph-1\n\nmoretext"
        cursor: [2, 0]
        register: "Paragraph-1\nParagraph-1\nParagraph-1\n\n"

    it "selects around the current paragraph in visual mode", ->
      ensure 'vap',
        selectedScreenRange: [[2, 0], [6, 0]]

  describe "the 'i[' text object", ->
    beforeEach ->
      set
        text: "[ something in here and in [here] ]"
        cursor: [0, 9]

    it "applies operators inside the current word in operator-pending mode", ->
      ensure 'di[',
        text: "[]"
        cursor: [0, 1]

    it "applies operators inside the current word in operator-pending mode (second test)", ->
      set
        cursor: [0, 29]
      ensure 'di[',
        text: "[ something in here and in [] ]"
        cursor: [0, 28]

  describe "the 'i\'' text object", ->
    beforeEach ->
      set
        text: "' something in here and in 'here' ' and over here"
        cursor: [0, 9]

    it "applies operators inside the current string in operator-pending mode", ->
      ensure "di'",
        text: "''here' ' and over here"
        cursor: [0, 1]

    # I don't like old behavior, that was not in Vim and furthermore, this is counter intuitive.
    # Simply selecting area between quote is that normal user expects.
    # it "applies operators inside the next string in operator-pending mode (if not in a string)", ->

    it "[Changed behavior] applies operators inside area between quote", ->
      set
        cursor: [0, 26]
      ensure "di'",
        text: "''here' ' and over here"
        cursor: [0, 1]

    it "makes no change if past the last string on a line", ->
      set
        cursor: [0, 39]
      ensure "di'",
        text: "' something in here and in 'here' ' and over here"
        cursor: [0, 39]

  describe "the 'i\"' text object", ->
    beforeEach ->
      set
        text: '" something in here and in "here" " and over here'
        cursor: [0, 9]

    it "applies operators inside the current string in operator-pending mode", ->
      ensure 'di"',
        text: '""here" " and over here'
        cursor: [0, 1]

    it "[Changed Behavior?] won't apply if quote is not within string", ->
      set
        cursor: [0, 29]
      ensure 'di"',
        text: '" something in here and in "here" " and over here'
        cursor: [0, 29]

    it "makes no change if past the last string on a line", ->
      set
        cursor: [0, 39]
      ensure 'di"',
        text: '" something in here and in "here" " and over here'
        cursor: [0, 39]

  describe "the 'aw' text object", ->
    beforeEach ->
      set
        text: "12345 abcde ABCDE"
        cursor: [0, 9]

    it "applies operators from the start of the current word to the start of the next word in operator-pending mode", ->
      ensure 'daw',
        text: "12345 ABCDE"
        cursor: [0, 6]
        register: "abcde "

    it "selects from the start of the current word to the start of the next word in visual mode", ->
      ensure 'vaw',
        selectedScreenRange: [[0, 6], [0, 12]]

    it "doesn't span newlines", ->
      set
        text: "12345\nabcde ABCDE"
        cursor: [0, 3]
      ensure 'vaw',
        selectedBufferRange: [[0, 0], [0, 5]]

    it "doesn't span special characters", ->
      set
        text: "1(345\nabcde ABCDE"
        cursor: [0, 3]
      ensure 'vaw',
        selectedBufferRange: [[0, 2], [0, 5]]

  describe "the 'aW' text object", ->
    beforeEach ->
      set
        text: "12(45 ab'de ABCDE"
        cursor: [0, 9]

    it "applies operators from the start of the current whole word to the start of the next whole word in operator-pending mode", ->
      ensure 'daW',
        text: "12(45 ABCDE"
        cursor: [0, 6]
        register: "ab'de "
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

    it "selects from the start of the current whole word to the start of the next whole word in visual mode", ->
      ensure 'vaW',
        selectedScreenRange: [[0, 6], [0, 12]]

    it "doesn't span newlines", ->
      set
        text: "12(45\nab'de ABCDE"
        cursor: [0, 4]
      ensure 'vaW',
        selectedBufferRange: [[0, 0], [0, 5]]

  describe "the 'a(' text object", ->
    beforeEach ->
      set
        text: "( something in here and in (here) )"
        cursor: [0, 9]

    it "applies operators around the current parentheses in operator-pending mode", ->
      ensure 'da(',
        text: ''
        cursor: [0, 0]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

    it "applies operators around the current parentheses in operator-pending mode (second test)", ->
      set
        cursor: [0, 29]
      ensure 'da(',
        text: "( something in here and in  )"
        cursor: [0, 27]

  describe "the 'a{' text object", ->
    beforeEach ->
      set
        text: "{ something in here and in {here} }"
        cursor: [0, 9]

    it "applies operators around the current curly brackets in operator-pending mode", ->
      ensure 'da{',
        text: ''
        cursor: [0, 0]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

    it "applies operators around the current curly brackets in operator-pending mode (second test)", ->
      set
        cursor: [0, 29]
      ensure 'da{',
        text: "{ something in here and in  }"
        cursor: [0, 27]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

  describe "the 'a<' text object", ->
    beforeEach ->
      set
        text: "< something in here and in <here> >"
        cursor: [0, 9]

    it "applies operators around the current angle brackets in operator-pending mode", ->
      ensure 'da<',
        text: ''
        cursor: [0, 0]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

    it "applies operators around the current angle brackets in operator-pending mode (second test)", ->
      set
        cursor: [0, 29]
      ensure 'da<',
        text: "< something in here and in  >"
        cursor: [0, 27]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

  describe "the 'a[' text object", ->
    beforeEach ->
      set
        text: "[ something in here and in [here] ]"
        cursor: [0, 9]

    it "applies operators around the current square brackets in operator-pending mode", ->
      ensure 'da[',
        text: ''
        cursor: [0, 0]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

    it "applies operators around the current square brackets in operator-pending mode (second test)", ->
      set
        cursor: [0, 29]
      ensure 'da[',
        text: "[ something in here and in  ]"
        cursor: [0, 27]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

  describe "the 'a\'' text object", ->
    originalText = "' something in here and in 'here' '"
    beforeEach ->
      set
        text: originalText
        cursor: [0, 9]

    it "applies operators around the current single quotes in operator-pending mode", ->
      ensure "da'",
        text: "here' '"
        cursor: [0, 0]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

    it "[Changed Behavior] wont applies if its not within string", ->
      set
        cursor: [0, 29]
      ensure "da'",
        text: originalText
        cursor: [0, 29]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

  describe "the 'a\"' text object", ->
    originalText = '" something in here and in "here" "'
    beforeEach ->
      set
        text: originalText
        cursor: [0, 9]

    it "applies operators around the current double quotes in operator-pending mode", ->
      ensure 'da"',
        text: 'here" "'
        cursor: [0, 0]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

    it "[Changed Behavior] wont applies if its not within string", ->
      set
        cursor: [0, 29]
      ensure 'da"',
        text: originalText
        cursor: [0, 29]
        classListContains: 'normal-mode'
        classListNotContains: 'operator-pending-mode'

  describe 'the "comment" text object', ->
    coffeeEditor = null
    vim = null
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-coffee-script')

      getVimState 'sample.coffee', (_vimState, _vim) ->
        coffeeEditor = _vimState.editor
        _vimState.activateNormalMode()
        _vimState.resetNormalMode()
        vim = _vim

    afterEach ->
      atom.packages.deactivatePackage('language-coffee-script')

    describe 'select inside comment', ->
      it 'select inside comment block', ->
        vim.set cursor: [0, 0]
        vim.ensure 'vi/',
          selectedText: '# This\n# is\n# Comment\n'
          selectedBufferRange: [[0, 0], [3, 0]]

      it 'select one line comment', ->
        vim.set cursor: [4, 0]
        vim.ensure 'vi/',
          selectedText: '# One line comment\n'
          selectedBufferRange: [[4, 0], [5, 0]]

      it 'not select non-comment line', ->
        vim.set cursor: [6, 0]
        vim.ensure 'vi/',
          selectedText: '# Comment\n# border\n'
          selectedBufferRange: [[6, 0], [8, 0]]

    describe 'select around comment', ->
      it 'include blank line when selecting comment', ->
        vim.set cursor: [0, 0]
        vim.ensure 'va/',
          selectedText: """
          # This
          # is
          # Comment

          # One line comment

          # Comment
          # border\n
          """
          selectedBufferRange: [[0, 0], [8, 0]]

  describe 'the "indent" text object', ->
    coffeeEditor = null
    vim = null
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-coffee-script')

      getVimState 'sample.coffee', (_vimState, _vim) ->
        coffeeEditor = _vimState.editor
        _vimState.activateNormalMode()
        _vimState.resetNormalMode()
        vim = _vim

    afterEach ->
      atom.packages.deactivatePackage('language-coffee-script')

    describe 'select inside indent', ->
      it 'select lines with deeper indent-level', ->
        vim.set cursor: [12, 0]
        vim.ensure 'vii',
          selectedBufferRange: [[12, 0], [15, 0]]

    describe 'select around indent', ->
      it 'wont stop on blank line when selecting indent', ->
        vim.set cursor: [12, 0]
        vim.ensure 'vai',
          selectedBufferRange: [[10, 0], [27, 0]]

  describe 'the "current-line" text object', ->
    beforeEach ->
      set
        text: """
          This is
            multi line
          text
          """

    describe 'select inside line', ->
      it 'select current line without including last newline', ->
        set cursor: [0, 0]
        ensure 'vil', selectedText: 'This is'

      it 'also skip leading white space', ->
        set cursor: [1, 0]
        ensure 'vil', selectedText: 'multi line'

    describe 'select around line', ->
      it 'select current line without including last newline as like `vil`', ->
        set cursor: [0, 0]
        ensure 'val', selectedText: 'This is'

      it 'wont skip leading white space not like `vil`', ->
        set cursor: [1, 0]
        ensure 'val', selectedText: '  multi line'

  describe 'the "entire" text object', ->
    text = null
    beforeEach ->
      text = """
        This is
          multi line
        text
        """
      set {text}
    describe 'select inside/around(same behavior) entire buffer', ->
      it 'select entire buffer', ->
        set cursor: [0, 0]
        ensure 'escape', selectedText: ''
        ensure 'vie', selectedText: text
        ensure 'escape', selectedText: ''
        ensure 'jjvie', selectedText: text

        ensure 'escape', selectedText: ''
        ensure 'vae', selectedText: text
        ensure 'escape', selectedText: ''
        ensure 'jjvae', selectedText: text

  describe "the pair-any text object", ->
    beforeEach ->
      set
        text: """
          .... "abc" ....
          .... 'abc' ....
          .... `abc` ....
          .... {abc} ....
          .... <abc> ....
          .... >abc< ....
          .... [abc] ....
          .... (abc) ....
          """
        cursor: [0, 7]

    it "applies operators any innner-pair and repeatable", ->
      ensure 'dis',
        text: """
          .... "" ....
          .... 'abc' ....
          .... `abc` ....
          .... {abc} ....
          .... <abc> ....
          .... >abc< ....
          .... [abc] ....
          .... (abc) ....
          """
      ensure 'j.j.j.j.j.j.j.',
        text: """
          .... "" ....
          .... '' ....
          .... `` ....
          .... {} ....
          .... <> ....
          .... >< ....
          .... [] ....
          .... () ....
          """
    it "applies operators any a-pair and repeatable", ->
      ensure 'das',
        text: """
          ....  ....
          .... 'abc' ....
          .... `abc` ....
          .... {abc} ....
          .... <abc> ....
          .... >abc< ....
          .... [abc] ....
          .... (abc) ....
          """
      ensure 'j.j.j.j.j.j.j.',
        text: """
          ....  ....
          ....  ....
          ....  ....
          ....  ....
          ....  ....
          ....  ....
          ....  ....
          ....  ....
          """

  describe 'the fold text object', ->
    coffeeEditor = null
    vim = null
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-coffee-script')

      getVimState 'sample.coffee', (_vimState, _vim) ->
        coffeeEditor = _vimState.editor
        _vimState.activateNormalMode()
        _vimState.resetNormalMode()
        vim = _vim

    afterEach ->
      atom.packages.deactivatePackage('language-coffee-script')

    describe 'inner fold', ->
      it 'select fold row range except stwart row', ->
        vim.set cursor: [13, 0]
        vim.ensure 'viz',
          selectedBufferRange: [[10, 0], [26, 0]]

      it 'select fold row range except stwart row', ->
        vim.set cursor: [19, 0]
        vim.ensure 'viz',
          selectedBufferRange: [[19, 0], [24, 0]]

    describe 'a fold', ->
      it 'select fold row range', ->
        vim.set cursor: [13, 0]
        vim.ensure 'vaz',
          selectedBufferRange: [[9, 0], [26, 0]]

      it 'select fold row range except stwart row', ->
        vim.set cursor: [19, 0]
        vim.ensure 'vaz',
          selectedBufferRange: [[18, 0], [24, 0]]
