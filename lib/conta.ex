defmodule Conta do
  defstruct usuario: Usuario, saldo: 1000

  def cadastrar(usuario), do: %__MODULE__{usuario: usuario}

  def transferir(contas, de, para, valor) do
    de = Enum.find(contas, fn conta -> conta.usuario.email == de.usuario.email end)

    cond do
      valida_saldo(de.saldo, valor) -> {:error, "Saldo insuficiente!"}
      true ->
        para = Enum.find(contas, fn conta -> conta.usuario.email == para.usuario.email end)
        de = %Conta{de | saldo: de.saldo - valor}
        para = %Conta{para | saldo: para.saldo + valor}
      {de, para}
    end
  end

  def sacar(conta, valor) do
    cond do
      valida_saldo(conta.saldo, valor) -> {:error, "Saldo insuficiente!"}
      true ->
        conta = %Conta{conta | saldo: conta.saldo - valor}
        {:ok, conta, "Mensagem de e-mail encaminhada"}
    end
  end

  defp valida_saldo(saldo, valor), do: saldo < valor
end
