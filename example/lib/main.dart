import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_provider/go_provider.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MaterialApp.router(routerConfig: goRouter));
}

class BlocCubit extends Cubit<String> {
  BlocCubit() : super('Hello from BlocCubit! 🚀');
}

final goRouter = GoRouter(
  routes: [
    GoProviderRoute(
      path: '/',
      providers: (state) => [ // ✅ can access GoRouterState
        BlocProvider(create: (_) => BlocCubit()),
      ],
      builder: (context, state) => const PageA(), // ✅ can access BlocCubit
      routes: [
        GoRoute(
          path: 'b',
          builder: (context, state) => const PageB(), // ✅ can access BlocCubit
        ),
      ],
    ),
    GoRoute(
      path: '/c',
      builder: (context, state) => const PageC(), // ❌ can't access BlocCubit
    ),
  ],
);

class PageA extends StatelessWidget {
  const PageA({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<BlocCubit>();

    return Scaffold(
      appBar: AppBar(title: Text('Page A - ${bloc.state}')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/b'),
              child: const Text('Go to Page B'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/c'),
              child: const Text('Go to Page C'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  const PageB({super.key});

  @override
  Widget build(BuildContext context) {
    final blocA = context.watch<BlocCubit>();

    return Scaffold(
      appBar: AppBar(title: Text('Page B - ${blocA.state}')),
    );
  }
}

class PageC extends StatelessWidget {
  const PageC({super.key});

  @override
  Widget build(BuildContext context) {
    final blocA = context.watch<BlocCubit?>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Page C - ${blocA?.state ?? 'Bloc not found 😔'}'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Go to Page A'),
        ),
      ),
    );
  }
}
