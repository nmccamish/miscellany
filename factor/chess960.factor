USING: accessors arrays assocs csv http.download
io.encodings.ascii io.encodings.strict io.encodings.string
io.files io.files.temp io.launcher io.pathnames kernel math
math.parser sequences sequences.extras sequences.private urls ;
IN: nam.chess960

CONSTANT: dataset-url URL" https://www.mark-weeks.com/cfaa/chess960/c960strt.zip"
ERROR: invalid-piece char ;
SYMBOLS: bishop king knight pawn queen rook ;

: place ( n seq elt -- ) -rot set-nth ;
: nth-empty ( n seq -- idx ) f swap nth-index ;
: set-first-empty ( elt seq -- ) 0 over nth-empty swap set-nth ;

: assert-rank-length ( rank -- rank )
    dup length 8 assert= ;

: piece-char>symbol ( char -- symbol )
    H{
        { CHAR: B bishop }
        { CHAR: K king   }
        { CHAR: N knight }
        { CHAR: P pawn   }
        { CHAR: Q queen  }
        { CHAR: R rook   }
    } ?at [ invalid-piece ] unless ;

: piece-symbol>string ( symbol -- string )
    H{
        { bishop "B" }
        { king   "K" }
        { knight "N" }
        { pawn   "P" }
        { queen  "Q" }
        { rook   "R" }
    } ?at [ invalid-piece ] unless ;

: rank-symbols>string ( symbols -- string )
    assert-rank-length
    [ piece-symbol>string ] map "" join ;

: rank-string>symbols ( string -- symbols )
    ascii strict decode
    assert-rank-length
    [ piece-char>symbol ] { } map-as ;

: chess960-position ( n -- pos )
    8 f <array> swap 4 /mod ! pos N2 B1
    1 shift 1 + pick bishop place ! pos N2
    4 /mod ! N3 B2
    1 shift pick bishop place ! N3
    6 /mod ! N4 Q
    pick f swap nth-index pick queen place ! N4
    B{ 0b00000001 ! N5N table, nth empty space
       0b00000010 ! low nibble  = 1st knight
       0b00000011 ! high nibble = 2nd knight
       0b00000100
       0b00010010
       0b00010011
       0b00010100
       0b00100011
       0b00100100
       0b00110100 } nth dup
    -4 shift pick nth-empty pick knight place
    0b1111 bitand 1 - ! minus 1, because of above op
    over nth-empty over knight place
    rook over set-first-empty
    king over set-first-empty
    rook over set-first-empty ;

: download-dataset ( -- )
    [
        dataset-url dup path>> file-name download-once-as
        { "unzip" "-nq" } swap suffix try-process
    ] with-cache-directory ;

: ?download-dataset ( -- )
    dataset-url path>> file-name cache-file file-exists? [ download-dataset ] unless ;

: test-dataset ( -- )
    download-dataset
    CHAR: | [ "C960STRT.TXT" cache-file ascii strict file>csv ] with-delimiter
    rest-slice [
        [ third-unsafe ] [ second-unsafe ] bi
        string>number chess960-position
        swap rank-string>symbols assert=
    ] each ;

test-dataset
