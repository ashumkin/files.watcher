#!/usr/bin/env python
# -*- encoding: utf-8 -*-

import sys, re, time, datetime

class Time(object):
    def __init__(self, seconds):
        self.seconds = seconds
        self.__timeformat = '%H:%M:%S'

    @property
    def string(self):
        return time.strftime(self.__timeformat, time.gmtime(self.seconds))

    @string.setter
    def string(self, value):
        x = time.strptime(value, self.__timeformat)
        self.seconds = datetime.timedelta(hours = x.tm_hour, minutes = x.tm_min, seconds = x.tm_sec).total_seconds()

class TimeParser(object):
    def __init__(self):
        self.time_s = Time(0)
        self.time_f = Time(0)

    @property
    def time(self):
        return '%s-%s' % (self.time_s.string, self.time_f.string)

    @time.setter
    def time(self, value):
        self.__parse_time(value)

    def __parse_time(self, value):
        m = re.search('(\d+:\d+:\d+)\s*-\s*(\d+:\d+:\d+)', value)
        if m is not None:
            self.time_s.string = m.group(1)
            self.time_f.string = m.group(2)
        else:
            m = re.search('(\d+:\d+:\d+)\s*-\s*(\d+)', value)
            if m is None:
                raise ValueError('`%s` is not a time range or start time and duration' % value)
            self.time_s.string = m.group(1)
            self.time_f.seconds = self.time_s.seconds + int(m.group(2))

    @property
    def __duration(self):
        return self.time_f.seconds - self.time_s.seconds

    def forffmpeg(self):
        return '-ss %s -t %d' % (self.time_s.string, self.__duration)

    def read_from_stdin(self):
        for line in sys.stdin:
            self.time = line
            # read first line only
            break

if __name__ == '__main__':
    tp = TimeParser()
    tp.read_from_stdin()
    print tp.forffmpeg()
