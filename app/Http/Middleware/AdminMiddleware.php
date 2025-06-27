<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
   public function handle(Request $request, \Closure $next): \Symfony\Component\HttpFoundation\Response
{
    $user = \Illuminate\Support\Facades\Auth::user();

    if (!$user || $user->role !== 'admin') {
        return response()->json([
            'message' => 'Acesso não autorizado. Apenas administradores podem acessar esta rota.'
        ], 403);
    }

    return $next($request);
}
}