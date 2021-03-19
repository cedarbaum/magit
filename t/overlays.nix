let overlay1 = self: super:
{
  (pkgs.emacsPackagesFor self).emacsWithPackages (
    epkgs: [
      epkgs.seq
      epkgs.dash
      epkgs.transient
    ] ++ (with epkgs.melpaPackages; [
      libgit
      with-editor
    ])
  )
};

