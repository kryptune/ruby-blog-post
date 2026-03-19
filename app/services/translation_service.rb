class TranslationService
  include HTTParty
  base_uri "http://localhost:5000"

  def translate(text, target_lang = "es")
    response = self.class.post("/translate", {
      body: {
        q: text,
        source: "en",
        target: target_lang,
        format: "text"
      }.to_json,
      headers: { "Content-Type" => "application/json" }
    })
    Rails.logger.info "RESPONSE: #{response.parsed_response.inspect}"
    response.parsed_response["translatedText"]

  end
end
