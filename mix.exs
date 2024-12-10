defmodule NervesMixTargetBug.MixProject do
  use Mix.Project

  @app :nerves_mix_target_bug
  @version "0.1.0"
  @all_targets [:rpi3, :custom_rpi3]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.17",
      archives: [nerves_bootstrap: "~> 1.13"],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      deps_path: "deps/#{Mix.target()}",
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host],
      lockfile: "#{Mix.target()}.mix.lock"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {NervesMixTargetBug.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.10", runtime: false},
      {:shoehorn, "~> 0.9.1"},
      {:ring_logger, "~> 0.11.0"},
      {:toolshed, "~> 0.4.0"},

      # Allow Nerves.Runtime on host to support development, testing and CI.
      # See config/host.exs for usage.
      {:nerves_runtime, "~> 0.13.0"},

      # Dependencies for all targets except :host
      {:nerves_pack, "~> 0.7.1", targets: @all_targets},

    ] ++ deps(Mix.target())
  end

  # Dependencies for specific targets
  # NOTE: It's generally low risk and recommended to follow minor version
  # bumps to Nerves systems. Since these include Linux kernel and Erlang
  # version updates, please review their release notes in case
  # changes to your application are needed.
  defp deps(:rpi3), do: [{:nerves_system_rpi3, "~> 1.24", runtime: false, targets: :rpi3}]
  defp deps(:custom_rpi3) do
    [
      {:custom_rpi3,
       runtime: false,
       git: "https://github.com/Damirados/custom_rpi3",
       branch: "gcc14-toolchain",
       targets: :custom_rpi3}
    ]
  end
  defp deps(_), do: []

  def release do
    [
      overwrite: true,
      # Erlang distribution is not started automatically.
      # See https://hexdocs.pm/nerves_pack/readme.html#erlang-distribution
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end
end
