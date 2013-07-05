#!/usr/bin/env python
# -*- encoding: utf-8 -*-

import os, sys, inspect
import unittest

# use this if you want to include modules from a subfolder
cmd_subfolder = os.path.realpath(os.path.abspath(os.path.join(os.path.split(inspect.getfile( inspect.currentframe() ))[0], "../helpers")))
if cmd_subfolder not in sys.path:
    sys.path.insert(0, cmd_subfolder)
import ffmpeg_time

class TestTime(unittest.TestCase):
    def setUp(self):
        self.time = ffmpeg_time.Time(124)

    def test_seconds(self):
        self.assertEqual(124, self.time.seconds)

    def test_string(self):
        self.assertEqual('00:02:04', self.time.string)
        self.time.string = '0:3:5'
        self.assertEqual(185, self.time.seconds)
        self.assertEqual('00:03:05', self.time.string)

class TestTimeParser(unittest.TestCase):

    def setUp(self):
        self.parser = ffmpeg_time.TimeParser()
        self.parser.time = '0:0:5-0:1:43'

    def test_time(self):
        self.assertEqual('00:00:05-00:01:43', self.parser.time)
        self.parser.time = '0:0:6 -   2:0:48'
        self.assertEqual('00:00:06-02:00:48', self.parser.time)
        self.parser.time = '0:0:6 -   25'
        self.assertEqual('00:00:06-00:00:31', self.parser.time)

    def test_forffmpeg(self):
        self.assertEqual('-ss 00:00:05 -t 98', self.parser.forffmpeg())
        self.parser.time = '0:0:6 -   25'
        self.assertEqual('-ss 00:00:06 -t 25', self.parser.forffmpeg())

    def test_incorrect_time(self):
        with self.assertRaises(ValueError):
            self.parser.time = '0::0:5'

if __name__ == '__main__':
    unittest.main()
