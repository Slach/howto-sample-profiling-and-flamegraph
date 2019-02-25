<?php
include '/opt/liveprof/vendor/autoload.php';
\Badoo\LiveProfiler\LiveProfiler::getInstance()
    ->setMode(\Badoo\LiveProfiler\LiveProfiler::MODE_DB)
    // optional, you can use environment variable LIVE_PROFILER_CONNECTION_URL
    ->setConnectionString('mysql://liveprof:liveprof@mysql:3306/liveprof?charset=utf8')
    ->setApp($_SERVER['HTTP_HOST'])->setLabel($_SERVER['REQUEST_URI'])
    //all scripts with same APP and LABEL will be profiled
    ->setDivider(1)
    //all scripts with ALL label will be profiled
    ->setTotalDivider(1)
    ->setStartCallback(function () {
        ini_set("xhprof.sampling_interval",20000); ini_set("xhprof.sampling_depth",200);
        define('XHPROF_SAMPLING_BEGIN',microtime(true));
        xhprof_sample_enable();
    })
    ->setEndCallback(function () {
        $xhprof_sampling=xhprof_sample_disable();
        $xhprof_full=array();
        $prev_time = XHPROF_SAMPLING_BEGIN;
        foreach ($xhprof_sampling as $time=>$callstack) {
            $xhprof_full[$callstack]['ct']++;
            $xhprof_full[$callstack]['wt'] += $time - $prev_time;
            $prev_time = $time;
        }
        foreach ($xhprof_full as $callstack=>$info) {
            $xhprof_full[$callstack]['wt'] = intval($info['wt'] * 1000000); # s -> ms
        }
        return $xhprof_full;
    })
    ->start();