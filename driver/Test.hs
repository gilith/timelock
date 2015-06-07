import qualified Data.ByteString.Char8 as B
import System.Hardware.Serialport

main :: IO ()
main =
    do let port = "COM3"          -- Windows
       --let port = "/dev/ttyUSB0"  -- Linux
       s <- openSerial port defaultSerialSettings { commSpeed = CS2400 }
       send s $ B.singleton 15
       recv s 1 >>= print
       closeSerial s
