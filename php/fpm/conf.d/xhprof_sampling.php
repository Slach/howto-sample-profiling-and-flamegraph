<?php
if (extension_loaded('xhprof')) {
  $uri = substr($_SERVER['REQUEST_URI'], 1);
  $uri = preg_replace('/[?\/]/', '-', $uri);
  # see https://github.com/longxinH/xhprof/pull/8
  ini_set("xhprof.sampling_interval",20000);
  ini_set("xhprof.sampling_depth",200);
  xhprof_sample_enable();
  register_shutdown_function(function () use($uri) {
    $filename = "/tmp/{$uri}." . uniqid() . ".sample_xhprof";
    file_put_contents($filename, serialize(xhprof_sample_disable()));
    chmod($filename, 0777);
  });
}
