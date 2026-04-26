#!/bin/bash

#this should only be needed if we haven't patched the instance in a long time
#pacman-key --refresh-keys

pacman -Syu --noconfirm
