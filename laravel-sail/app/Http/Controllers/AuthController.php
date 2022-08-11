<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Hash;
use Auth;
use Validator;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required',
            'email' => 'required|email|unique:users',
            'password' => 'required',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'message' => $validator->errors(),
            ], 401);
        }
        $input = $request->only(['name', 'email', 'password']);
        $input['password'] = Hash::make($input['password']);
        $user = User::create($input);
        $token = $user->createToken('appToken')->accessToken;
        return response()->json([
            'token' => $token,
            'user' => $user
        ], 200);
    }

    public function login()
    {
        if (Auth::attempt(['email' => request('email'), 'password' => request('password')])) {
            $user = Auth::user();
            $token = $user->createToken('appToken')->accessToken;
            return response()->json([
                'token' => $token,
                'user' => $user
            ], 200);
        } else {
            return response()->json([
                'message' => 'Invalid Email or Password',
            ], 401);
        }
    }

    public function logout(Request $res)
    {
        if (Auth::check()) {
            $user = Auth::user()->token();
            $user->revoke();

            return response()->json([
                'success' => true,
            ], 200);
        } else {
            return response()->json([
                'success' => false,
            ], 200);
        }
    }
}
