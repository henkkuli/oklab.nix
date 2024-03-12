{ math, ... }@inputs:
let
  tou8 =
    x:
    let
      r = builtins.floor (255 * x);
    in
    if r < 0 then
      0
    else if r > 255 then
      255
    else
      r;

  toHexImpl =
    letters:
    assert builtins.stringLength letters == 16;
    let
      iter =
        len: x:
        if len <= 0 then
          ""
        else
          let
            digit = builtins.bitAnd 15 x;
            rest = x / 16;
          in
          iter (len - 1) rest + (builtins.substring digit 1 letters);
    in
    iter;

  toHex = toHexImpl "0123456789abcdef";
  toHEX = toHexImpl "0123456789ABCDEF";

  fromHex =
    let
      parseDigit =
        x:
        if x == "0" then
          0
        else if x == "1" then
          1
        else if x == "2" then
          2
        else if x == "3" then
          3
        else if x == "4" then
          4
        else if x == "5" then
          5
        else if x == "6" then
          6
        else if x == "7" then
          7
        else if x == "8" then
          8
        else if x == "9" then
          9
        else if x == "a" || x == "A" then
          10
        else if x == "b" || x == "B" then
          11
        else if x == "c" || x == "C" then
          12
        else if x == "d" || x == "D" then
          13
        else if x == "e" || x == "E" then
          14
        else if x == "f" || x == "F" then
          15
        else
          assert false;
          0;

      iter =
        x:
        let
          xlen = builtins.stringLength x;
          iter =
            res: idx:
            if idx >= xlen then
              # At the end
              res
            else
              iter (16 * res + parseDigit (builtins.substring idx 1 x)) (idx + 1);
        in
        iter 0;
    in
    x:
    if builtins.match "^#.*" x != null then
      # Remove starting hash
      iter x 1
    else
      iter x 0;
in
{
  inherit
    tou8
    toHex
    toHEX
    fromHex
    ;
}
