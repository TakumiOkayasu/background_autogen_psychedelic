enum ShaderPattern {
  marble, vortex, ripple, fractal, plasma, sentai,
  liquid, kaleidoscope, explosion, turbulence, acid, warp;

  String get assetPath => 'shaders/psychedelic_$name.frag';
  String get label => name[0].toUpperCase() + name.substring(1);
}
