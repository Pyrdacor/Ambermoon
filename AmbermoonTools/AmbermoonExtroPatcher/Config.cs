using System.Text.Json;
using System.Text.Json.Serialization;

namespace AmbermoonExtroPatcher;

public class Config
{
    [JsonPropertyName("extro_path")]
    public string? ExtroPath { get; set; }

    [JsonPropertyName("text_path")]
    public string? TextPath { get; set; }

    [JsonPropertyName("output_path")]
    public string? OutputPath { get; set; }

    [JsonPropertyName("font_file")]
    public string? FontFile { get; set; }

    [JsonPropertyName("codepage")]
    public int? CodePage { get; set; }

    [JsonPropertyName("encoding")]
    public string? Encoding { get; set; }

    [JsonPropertyName("click_text")]
    public string? ClickText { get; set; }

    [JsonPropertyName("translators")]
    public List<string> Translators { get; set; } = [];

    public static Config Load(string filePath)
    {
        var json = File.ReadAllText(filePath);

        return JsonSerializer.Deserialize<Config>(json) ?? new Config();
    }
}
