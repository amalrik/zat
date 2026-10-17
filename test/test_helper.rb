# frozen_string_literal: true

# Loads nothing from Zat on purpose: test/markdown/ must run with only
# zat/markdown loaded. Each test file requires what it exercises.
require "minitest/autorun"

# Ractors are part of the design; their "experimental" warning would
# otherwise drown the -w output of every test that uses one.
Warning[:experimental] = false
