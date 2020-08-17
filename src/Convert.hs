module Convert (
  convert
) where

import Text.Pandoc.App (convertWithOpts, defaultOpts, Opt(..))
import Text.Pandoc.Options (WrapOption (WrapPreserve))

convert :: FilePath -> FilePath -> IO ()
convert inputFile outputFile = convertWithOpts $ defaultOpts { optInputFiles   = Just [inputFile]
                                                             , optOutputFile   = Just outputFile
                                                             , optReferenceDoc = Just "Ref.docx"
                                                             , optWrap         = WrapPreserve
                                                             }
