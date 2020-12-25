defmodule Conta do
  defstruct usuario: Usuario, saldo: 1000
  @contas "contas.txt"
  def cadastrar(usuario) do
    case buscar_por_email(usuario.email) do
      nil ->
        binary = [%__MODULE__{usuario: usuario}]  ++ busca_contas()
        |> :erlang.term_to_binary()
        File.write(@contas, binary)
      _ -> {:error, "Conta ja cadastrada!"}
    end

  end

  def busca_contas do
    {:ok, binary} = File.read(@contas)
    :erlang.binary_to_term(binary)
  end

  def buscar_por_email(email), do: Enum.find(busca_contas(), &(&1.usuario.email == email))

  def transferir(de, para, valor) do
    de = buscar_por_email(de.usuario.email)

    cond do
      valida_saldo(de.saldo, valor) -> {:error, "Saldo insuficiente!"}
      true ->
        contas = busca_contas()
        contas = List.delete contas, de
        contas = List.delete contas, para
        de = %Conta{de | saldo: de.saldo - valor}
        para = %Conta{para | saldo: para.saldo + valor}
        contas = contas ++ [de, para]
        File.write(@contas, :erlang.term_to_binary(contas))
    end
  end

  def sacar(conta, valor) do
    cond do
      valida_saldo(conta.saldo, valor) -> {:error, "Saldo insuficiente!"}
      true ->
        contas = busca_contas()
        contas = List.delete contas, conta
        conta = %Conta{conta | saldo: conta.saldo - valor}
        contas = contas ++ [conta]
        File.write(@contas, :erlang.term_to_binary(contas))
        {:ok, conta, "Mensagem de e-mail encaminhada"}
    end
  end

  # defp é uma funcao privada
  defp valida_saldo(saldo, valor), do: saldo < valor
end
