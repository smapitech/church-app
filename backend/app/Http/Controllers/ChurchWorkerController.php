<?php

namespace App\Http\Controllers;

use App\Models\ChurchWorker;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ChurchWorkerController extends Controller
{
    public function index(Request $request)
    {
        $query = ChurchWorker::with('user')
            ->where('status', 'active')
            ->orderBy('department', 'asc');

        if ($request->has('department')) {
            $query->where('department', $request->department);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->whereHas('user', function ($q) use ($search) {
                $q->where('name', 'like', '%' . $search . '%')
                    ->orWhere('email', 'like', '%' . $search . '%');
            });
        }

        $workers = $query->paginate($request->get('per_page', 50));

        return response()->json([
            'message' => 'Church workers retrieved successfully',
            'data' => $workers
        ]);
    }

    public function show($id)
    {
        $worker = ChurchWorker::with('user')->findOrFail($id);

        return response()->json([
            'message' => 'Worker retrieved successfully',
            'data' => $worker
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id|unique:church_workers',
            'department' => 'required|in:choir,pastoral,usher,admin,security,youth,nursery,outreach,other',
            'position' => 'required|string|max:255',
            'joining_date' => 'required|date',
            'phone' => 'nullable|string|max:20',
            'email' => 'nullable|email',
            'bio' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $worker = ChurchWorker::create($request->only([
            'user_id', 'department', 'position', 'joining_date', 'phone', 'email', 'bio'
        ]));

        return response()->json([
            'message' => 'Worker created successfully',
            'data' => $worker
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $worker = ChurchWorker::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'department' => 'in:choir,pastoral,usher,admin,security,youth,nursery,outreach,other',
            'position' => 'string|max:255',
            'status' => 'in:active,inactive,on_leave',
            'phone' => 'nullable|string|max:20',
            'email' => 'nullable|email',
            'bio' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $worker->update($request->only([
            'department', 'position', 'status', 'phone', 'email', 'bio'
        ]));

        return response()->json([
            'message' => 'Worker updated successfully',
            'data' => $worker
        ]);
    }

    public function destroy($id)
    {
        $worker = ChurchWorker::findOrFail($id);
        $worker->delete();

        return response()->json([
            'message' => 'Worker deleted successfully'
        ]);
    }

    public function getByDepartment($department)
    {
        $workers = ChurchWorker::where('department', $department)
            ->where('status', 'active')
            ->with('user')
            ->get();

        return response()->json([
            'message' => "Workers from $department department retrieved successfully",
            'data' => $workers
        ]);
    }
}
