defmodule Invoice.Accounts.UserNotifier do
  import Swoosh.Email

  alias Invoice.Mailer

  alias Invoice.EmailTemplateHelpers.ConfirmationInstructions
  alias Invoice.EmailTemplateHelpers.ResetPasswordInstructions
  alias Invoice.EmailTemplateHelpers.UpdateEmailInstructions

  defp deliver(recipient, subject, html_body, text_body) do
    email =
      new()
      |> to(recipient)
      |> from({"InvoiceGenerator", "contact@example.com"})
      |> subject(subject)
      |> html_body(html_body)
      |> text_body(text_body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, confirmation_url) do
    rendered_email =
      ConfirmationInstructions.render(
        confirmation_url: confirmation_url,
        email: user.email,
        name: user.username
      )

    text_body = confirmation_instructions_text(user, confirmation_url)

    deliver(user.email, "Confirm your email at GenInvoice", rendered_email, text_body)
  end

  defp confirmation_instructions_text(user, url) do
    """
    Hi #{user.username},

    Please take a second to confirm #{user.email} as your email address:

    Once you do, you'll be able to opt-in for notifications of activity and
    access other features that require a valid email address.

    #{url}

    If you didn't create an account with us, please ignore this.

    ====
    Cheers!
    Team GenInvoice
    """
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    rendered_email =
      ResetPasswordInstructions.render(
        reset_password_url: url,
        email: user.email,
        name: user.name
      )

    text_body = reset_password_instructions_text(user, url)

    deliver(user.email, "Reset your password at GenInvoice", rendered_email, text_body)
  end

  defp reset_password_instructions_text(user, url) do
    """
    Hi #{user.username},

    Can't remember your GenInvoice password for #{ user.email }?

    That's OK, it happens. Just follow the link below to set a new one.

    #{url}

    If you didn't request a password reset you can safely ignore this email, it expires in 20 minutes.
    Only someone with access to this email account can reset your password.

    =====
    Cheers!
    Team GenInvoice
    """
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    rendered_email =
      UpdateEmailInstructions.render(
        reset_email_url: url,
        email: user.email,
        name: user.username
      )

    text_body = update_email_instructions_text(user, url)

    deliver(user.email, "Update your email at GenInvoice", rendered_email, text_body)
  end

  defp update_email_instructions_text(user, url) do
    """
    Hi #{user.username},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ====
    Cheers!
    Team GenInvoice
    """
  end
end
