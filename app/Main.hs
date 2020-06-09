{-# LANGUAGE OverloadedStrings #-}
import Network.Wai.Handler.Warp (runSettings, defaultSettings, setHost, setPort)
import Lib (app)

main :: IO ()
main = do
  let port = 8080
  putStrLn $ "Listening on port " ++ show port
  let settings = setPort port $ setHost "0.0.0.0" defaultSettings
  runSettings settings app
