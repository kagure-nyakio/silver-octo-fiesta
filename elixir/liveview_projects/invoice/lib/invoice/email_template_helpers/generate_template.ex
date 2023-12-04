defmodule Invoice.EmailTemplateHelpers.GenerateTemplate do
  def generate_template(file_path) do
    {:ok, template} =
      file_path
      |> File.read!()
      |> Mjml.to_html()

    ~r/{{\s*([^}^\s]+)\s*}}/
    |> Regex.replace(template, fn _, variable_name ->
      "<%= @#{variable_name} %>"
    end)
  end
end
