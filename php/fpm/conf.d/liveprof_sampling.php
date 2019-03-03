<?php
include '/opt/liveprof/vendor/autoload.php';
$liveprof = \Badoo\LiveProfiler\LiveProfiler::getInstance();
$liveprof->setMode(\Badoo\LiveProfiler\LiveProfiler::MODE_DB)
    // optional, you can use environment variable LIVE_PROFILER_CONNECTION_URL
    ->setConnectionString('mysql://liveprof:liveprof@mysql:3306/liveprof?charset=utf8')
    ->setApp($_SERVER['HTTP_HOST'])->setLabel($_SERVER['REQUEST_URI'])
    //all scripts with same APP and LABEL will be profiled
    ->setDivider(1)
    //all scripts with ALL label will be profiled
    ->setTotalDivider(1);
$liveprof->useXhprofSample();
$liveprof->start();