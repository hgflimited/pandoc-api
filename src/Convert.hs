module Convert (
  convert
) where

import Text.Pandoc.App (convertWithOpts, defaultOpts, Opt(..))

convert :: FilePath -> FilePath -> IO ()
convert inputFile outputFile = convertWithOpts $ defaultOpts { optInputFiles = Just [inputFile]
                                                             , optOutputFile = Just outputFile
                                                             }
                                                               
