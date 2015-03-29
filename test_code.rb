require 'strscan'

@buffer = StringScanner.new(
  '(100) "testing!123"
  if test == 1 {
    while testing {
      a = 3
    }
  }
  ()'
)

@buffer = StringScanner.new(
  'test = 1
   abc  = 3
   if test == 1 {
     while testing {
       a = 3
     }
   puts (abc)
  }'
)

@buffer = StringScanner.new(
  'test = 2
   abc  = 10
   test = 500
   test += 10
   puts(test)
   if test == 1 {
    while testing {
      a = 3
    }
   }'
)
