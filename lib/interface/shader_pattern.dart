enum ShaderPattern {
  marble('shaders/psychedelic_marble.frag', 'Marble'),
  vortex('shaders/psychedelic_vortex.frag', 'Vortex'),
  ripple('shaders/psychedelic_ripple.frag', 'Ripple'),
  fractal('shaders/psychedelic_fractal.frag', 'Fractal'),
  plasma('shaders/psychedelic_plasma.frag', 'Plasma'),
  sentai('shaders/psychedelic_sentai.frag', 'Sentai');

  const ShaderPattern(this.assetPath, this.label);

  final String assetPath;
  final String label;
}
