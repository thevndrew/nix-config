inputs: {
  default = {
    path = ./flakeParts;
    description = "an empty flake with flake parts";
  };
  flakeParts = {
    path = ./flakeParts;
    description = "an empty flake with flake parts";
  };
  emptyFlake = {
    path = ./emptyFlake;
    description = "an empty flake";
  };
  flakeSchema = {
    path = ./flakeSchema;
    description = "an empty flake schema copy paste";
  };
  helloC = {
    path = ./helloC;
    description = "an C empty flake that is probably not how you are meant to do it at all plz send help";
  };
  hx-gotempl = {
    path = ./hx-gotempl;
    description = "an empty go + templ + htmx flake template";
  };
  luaFlake = {
    path = ./luaFlake;
    description = "an empty flake for a compiled lua application";
  };
  flakescript = {
    path = ./flakescript;
    description = "a tiny flake that outputs an overlay and a package containing a shell script";
  };
}
