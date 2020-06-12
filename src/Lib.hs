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

pathToFileExtensionMap :: [(B.ByteString, String)]
pathToFileExtensionMap = [ ("/pdf/", "pdf")
                         , ("/docx/", "docx")
                         ]

fileExtensionFromPath :: B.ByteString -> String
fileExtensionFromPath path = fileExtensionFromPath' $ lookup path pathToFileExtensionMap

fileExtensionFromPath' :: Maybe String -> String
fileExtensionFromPath' Nothing  = "html" -- default to html
fileExtensionFromPath' (Just e) = e

app :: Application
app request respond = do
  file <- runResourceT . withInternalState $ \s -> convertRequestFile s request $ fileExtensionFromPath $ rawPathInfo request
  respond $ respondWithFile file

convertRequestFile internalState request fileType = do
  (_, files) <- parseRequestBody (tempFileBackEndOpts getTemporaryDirectory ".md" internalState) request
  file <- convertFile ( getFile $ head files ) ("response." ++ fileType)
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

