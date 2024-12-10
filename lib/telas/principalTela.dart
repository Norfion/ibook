// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_p1/main.dart';
import 'package:projeto_p1/telas/principal/bibliotecaTela.dart';
import '../controladores/pedidoControlador.dart';
import '../controladores/usuarioControlador.dart';
import '../modelos/pedido.dart';
import '../modelos/usuario.dart';
import 'principal/perfilTela.dart';
import 'principal/carrinhoTela.dart';

// Variaveis globais
Pedido? pedido;
Usuario? usuario;
int qtdLivros = pedido!.getQuantidade();

class PrincipalTela extends StatefulWidget {
  const PrincipalTela({super.key});

  @override
  State<PrincipalTela> createState() => _PrincipalTelaState();
}

class _PrincipalTelaState extends State<PrincipalTela> {
  double tamFonteTag = 14;
  int _selectedIndex = 0;
  bool carregando = true;


  // Lista de telas
  late List<Widget> telas;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await carregarUsuario(currentUser.uid);
      await carregarPedido(currentUser.uid);
    }
    setState(() {
      telas = [
        const BibliotecaTela(),
        const Carrinhotela(),
        const PerfilTela(),
      ];
      carregando = false;
    });
  }

  Future<void> carregarPedido(String uidUsuario) async {
    await carregarUsuario(uidUsuario);
    try {
      Pedido? pedidoCarregado = await PedidoControlador().getPedido(uidUsuario);
      setState(() {
        pedido = pedidoCarregado;
      });
    } catch (error) {
      print("Erro ao carregar pedido: $error");
    }
  }

  Future<void> carregarUsuario(String uidUsuario) async {
    try {
      Usuario? usuarioCarregado = await UsuarioControlador()
          .getUsuario(FirebaseAuth.instance.currentUser!.uid.toString());
      if (usuarioCarregado != null) {
        setState(() {
          usuario = usuarioCarregado;
        });
      }
    } catch (error) {
      print("Erro ao carregar usuário: $error");
    }
  }

  // Atualiza o índice
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corSecundaria,
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : telas[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: corPrimaria),
            activeIcon: Icon(Icons.book, color: corTerciaria),
            label: 'Livros',
          ),
          BottomNavigationBarItem(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, color: corPrimaria),
                if (pedido != null)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 12, minHeight: 12),
                    child: Text(
                      '$qtdLivros',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: tamFonteTag,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            activeIcon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, color: corTerciaria),
                if (pedido != null)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 12, minHeight: 12),
                    child: Text(
                      '$qtdLivros',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: tamFonteTag,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            label: 'Carrinho',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: corPrimaria),
            activeIcon: Icon(Icons.person, color: corTerciaria),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: corTerciaria,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
