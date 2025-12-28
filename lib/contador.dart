
class Contador {
  int valor = 0;

  void incrementar() {
    valor++;
  }

  void decrementar() {
    valor--;
  }

  lerDoBanco(ContadorDatabase db) async {
    int dbValor = await db.ler();
    valor = dbValor;
  }

  salvarNoBanco(ContadorDatabase db) async {
    db.salvar(valor);
  }

  List<int> multiplicarValor(List<int> listaParaMultiplicar) {
    if (listaParaMultiplicar.isEmpty) throw ListaVaziaException();
    for (int numero in listaParaMultiplicar) {
      numero = numero * valor;
    }
    return listaParaMultiplicar;
  }
}

class ListaVaziaException implements Exception {
  @override
  String toString() => 'A lista fornecida está vazia.';
}

class ContadorDatabase {
  Future<void> abrirBanco() async {
    //... Abre o banco
  }

  Future<void> fecharBanco() async {
    //... Fecha o banco
  }

  Future<void> salvar(int valor) async {
    //... Salva `valor` no banco
    throw UnimplementedError();
  }

  Future<int> ler() async {
    //... Recupera `valor` no banco
    throw UnimplementedError();
  }

  Future<int> remover() async {
    //... Remove valor do banco
    throw UnimplementedError();
  }
}
