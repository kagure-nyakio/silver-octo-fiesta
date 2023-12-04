defmodule Invoice.EmailTemplateHelpers.ConfirmationInstructions do
  @template_path Path.join(__DIR__, "/email_templates/confirmation_instructions.mjml")
  @external_resource @template_path

  require EEx

  import Invoice.EmailTemplateHelpers.GenerateTemplate

  rendered_mjml = generate_template(@template_path)
  EEx.function_from_string(:def, :render, rendered_mjml, [:assigns])
end
