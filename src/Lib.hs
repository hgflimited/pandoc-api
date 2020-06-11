{-# LANGUAGE OverloadedStrings #-}
module Lib (
  app
) where

import Control.Monad.Trans.Resource
import Network.Wai
import Network.Wai.Parse (FileInfo (..), parseRequestBody, tempFileBackEndOpts)
import Network.HTTP.Types
import Network.Mime (defaultMimeLookup)
import System.Directory (getTemporaryDirectory)
import qualified Data.ByteString.Char8 as B
import qualified Data.Text as T
import Convert (convert)

app :: Application
app request respond = do
  file <- runResourceT . withInternalState $ \s -> convertRequestFile s request
  respond $ respondWithFile file

convertRequestFile internalState request = do
  (_, files) <- parseRequestBody (tempFileBackEndOpts getTemporaryDirectory ".md" internalState) request
  file <- convertFile ( getFile $ head files ) "response.pdf"
  return file

convertFile :: FilePath -> FilePath -> IO FilePath
convertFile inPath outPath = do
  convert inPath outPath
  return outPath

getFile :: (B.ByteString, FileInfo FilePath) -> FilePath
getFile (_, (FileInfo _ _ fileContent)) = fileContent

respondWithFile :: FilePath -> Response
respondWithFile path = responseFile
 status200
 [("Content-Type", defaultMimeLookup $ T.pack path)]
 path
 Nothing
