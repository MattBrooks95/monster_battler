module Helpers.Printing where

hashBorder = "###############################"

printWithBorder :: (Show a) => a -> IO ()
printWithBorder x = do
	print hashBorder
	print x
	print hashBorder
