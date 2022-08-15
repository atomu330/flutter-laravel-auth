<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Hash;
use Auth;
use Validator;
use Log;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8',
        ]);
        if ($validator->fails()) {
            $returnMessage = "";
            foreach ($validator->errors()->toArray() as $key => $errorMessages) {
                foreach ($errorMessages as $errorMessage) {
                    $returnMessage .= $errorMessage;
                    $returnMessage .= "\n";
                }
            }
            return response()->json([
                'message' => $returnMessage,
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

    public function login(Request $request)
    {
        $email = $request->input("email");
        $password = $request->input("password");
        Log::info($email);
        Log::info($password);
        if (Auth::attempt(['email' => $email, 'password' => $password])) {
            $user = Auth::user();
            $token = $user->createToken('appToken')->accessToken;
            return response()->json([
                'token' => $token,
                'user' => $user
            ], 200);
        } else {
            return response()->json([
                'message' => '入力されたメールアドレスとパスワードに誤りがあります。',
            ], 401);
        }
    }

    public function logout(Request $res)
    {
        if (Auth::check()) {
            $user = Auth::user()->token();
            $user->revoke();

            return response()->json([], 200);
        } else {
            return response()->json([
                'message' => '会員情報を取得できませんでした。',
            ], 401);
        }
    }
}
