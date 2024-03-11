{ math, ... }:
let
  # Source: https://bottosson.github.io/posts/colorwrong/#what-can-we-do%3F
  srgbTransfer = math.ffun (
    x: if x >= 3.1308e-3 then 1.055 * (math.pow x (1.0 / 2.4)) - 5.5e-2 else 12.92 * x
  );
  srgbTransferInv = math.ffun (
    x: if x >= 4.045e-2 then math.pow ((x + 5.5e-2) / (1 + 5.5e-2)) 2.4 else x / 12.92
  );

  # Source: https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab
  # Create color from sRGB colors within range [0, 1].
  srgb =
    r: g: b:
    let
      # Linearize srgb
      rLin = srgbTransfer r;
      gLin = srgbTransfer g;
      bLin = srgbTransfer b;
      # Convert to oklab
      l = math.cbrt (0.4122214708 * rLin + 0.5363325363 * gLin + 5.14459929e-2 * bLin);
      m = math.cbrt (0.2119034982 * rLin + 0.6806995451 * gLin + 0.1073969566 * bLin);
      s = math.cbrt (8.83024619e-2 * rLin + 0.2817188376 * gLin + 0.6299787005 * bLin);
    in
    oklab (0.2104542553 * l + 0.793617785 * m - 4.0720468e-3 * s)
      (1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s)
      (2.59040371e-2 * l + 0.7827717662 * m - 0.808675766 * s);

  toHex =
    len: v:
    if len <= 0 then
      ""
    else
      let
        b = builtins.bitAnd 15 v;
        letters = [
          "0"
          "1"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
          "9"
          "a"
          "b"
          "c"
          "d"
          "e"
          "f"
        ];
      in
      toHex (len - 1) (v / 16) + (builtins.elemAt letters b);

  toHEX =
    len: v:
    if len <= 0 then
      ""
    else
      let
        b = builtins.bitAnd 15 v;
        letters = [
          "0"
          "1"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
          "9"
          "A"
          "B"
          "C"
          "D"
          "E"
          "F"
        ];
      in
      toHEX (len - 1) (v / 16) + builtins.elemAt letters b;

  # oklabToRgb = 

  oklab =
    L: a: b:
    let
      lch = oklch L (math.sqrt (a * a + b * b)) (math.atan2 b a);
    in
    {
      inherit L a b;
      # oklch = oklch L a b;

      # Color conversion functions
      # Lighten or derken the color by additive factor. This is _not_ the smae as exposure change.
      lighten = math.ffun (amount: oklab (L + amount) a b);
      darken = math.ffun (amount: oklab (L - amount) a b);
      # Scale the color. This corresponds to change in exposure.
      scale = math.ffun (amount: oklab (L * amount) (a * amount) (b * amount));
      # Find the complementary color.
      complementary = math.ffun (oklab L (-a) (-b));
      # Add more staration to the color.
      saturate = math.ffun (amount: (lch.saturate amount).oklab);
      # Rotate the hue of the color.
      rotate = math.ffun (amount: (lch.rotate amount).oklab);

      # Color space conversions
      rgb =
        let
          l_ = L + 0.3963377774 * a + 0.2158037573 * b;
          m_ = L - 0.1055613458 * a - 6.38541728e-2 * b;
          s_ = L - 8.94841775e-2 * a - 1.291485548 * b;

          l = l_ * l_ * l_;
          m = m_ * m_ * m_;
          s = s_ * s_ * s_;

          rLin = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
          gLin = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
          bLin = -4.1960863e-3 * l - 0.7034186147 * m + 1.707614701 * s;

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
        in
        rec {
          r = srgbTransferInv rLin;
          g = srgbTransferInv gLin;
          b = srgbTransferInv bLin;
          ru8 = tou8 r;
          gu8 = tou8 g;
          bu8 = tou8 b;
          hex = "${toHex 2 ru8}${toHex 2 gu8}${toHex 2 bu8}";
          hexh = "#${hex}";
          HEX = "${toHEX 2 ru8}${toHEX 2 gu8}${toHEX 2 bu8}";
          HEXh = "#${HEX}";
        };

      oklch = lch;
    };

  oklch =
    L: C: h:
    let
      lab = oklab L (C * math.cos h) (C * math.sin h);
    in
    {
      inherit L C h;

      # Rotate the hue of the color.
      rotate = math.ffun (amount: oklch L C (h + amount));
      # Add more staration to the color.
      saturate = math.ffun (amount: oklch L (C + amount) h);

      oklab = lab;
    };
in
{
  inherit oklab srgb oklch;
}
