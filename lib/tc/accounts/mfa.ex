defmodule Tc.Accounts.Mfa do

  def generate_uri(username, secret) do
    NimbleTOTP.otpauth_uri("Tc:#{username}", secret, issuer: "Tc")
  end

  def generate_qrcode(uri) do
    uri
    |> EQRCode.encode()
    |> EQRCode.svg(width: 264)
    |> Phoenix.HTML.raw()
  end
end
