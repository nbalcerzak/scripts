#!/bin/bash

nohup mkfs.ext4 /dev/mapper/360000970000197801627533030333444p1 >/dev/null 2>&1 &
nohup mkfs.ext4 /dev/mapper/360000970000197801627533030333445p1 >/dev/null 2>&1 &

e2fsck -f /dev/mapper/360000970000197801627533030333444p1 >/dev/null 2>&1 &
resize2fs /dev/mapper/360000970000197801627533030333444p1 >/dev/null 2>&1 &
e2fsck -f /dev/mapper/360000970000197801627533030333445p1 >/dev/null 2>&1 &
resize2fs /dev/mapper/360000970000197801627533030333445p1 >/dev/null 2>&1 &

nohup parted /dev/mapper/360000970000197801627533030333444 resizepart 1 100% >/dev/null 2>&1 &
nohup parted /dev/mapper/360000970000197801627533030333445 resizepart 1 100% >/dev/null 2>&1 &

nohup pvresize /dev/mapper/360000970000197801627533030333444p1 >/dev/null 2>&1 &
nohup pvresize /dev/mapper/360000970000197801627533030333445p1 >/dev/null 2>&1 &

nohup e2fsck -f /dev/mapper/360000970000197801627533030333444p1 >/dev/null 2>&1 &
nohup resize2fs /dev/mapper/360000970000197801627533030333444p1 >/dev/null 2>&1 &

nohup e2fsck -f /dev/mapper/360000970000197801627533030333444p1 >/dev/null 2>&1 &
nohup resize2fs /dev/mapper/360000970000197801627533030333445p1 >/dev/null 2>&1 &
