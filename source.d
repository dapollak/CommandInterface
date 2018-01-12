import std.stdio;
import std.algorithm;
import std.traits;
import std.meta;
import std.conv;
import std.string;


struct Command {
	static int add(int a, int b) {
		return a+b;
	}

	static int square(int a) {
		return a*a;
	}

	static string mulString(string s, int num) {
		string res;
		foreach (i; 0..num) {
			res ~= s;
		}

		return res;
	}

	static int mul(int a, int b) {
		return a*b;
	}
}

struct caller(alias T) {
	// args decleration
	static foreach (i, p; Parameters!T) {
		mixin(p.stringof ~ " arg" ~ to!string(i) ~ ";");
	}

	void call() {
		enum int numOfParams = Parameters!T.length;

		string genArgsString(int numOfParams) {
			string args = "";
			foreach (i; 0..numOfParams) {
				args ~= "arg" ~ to!string(i) ~ ", ";
			}

			return args[0..$-2];
		}

		enum string finalArgs = genArgsString(numOfParams);
		mixin("writeln("~fullyQualifiedName!T~"("~finalArgs~"));");
	}
}

void makeCmd(T)(string[] args) {
	foreach (method; __traits(allMembers, T)) {
		if (args[1] == method) {
			mixin("caller!("~fullyQualifiedName!T~"."~method~") c;");

			mixin("enum int numOfParams = Parameters!("~fullyQualifiedName!T~"."~method~").length;");
			mixin("alias paramTypes = Parameters!("~fullyQualifiedName!T~"."~method~");");

			string genAssigmentString(int numOfParams)() {
				string res = "";
				foreach (i; 0..numOfParams) {
					res ~= "c.arg"~to!string(i)~" = to!(paramTypes["~to!string(i)~"])(args["~to!string(i+2)~"]);";
				}

				return res;
			}

			enum string assignmentString = genAssigmentString!(numOfParams)();

			//pragma (msg, assignmentString);
			mixin(assignmentString);

			// Final Call
			c.call();
		}
	}
}

int main(string[] argv)
{
	makeCmd!Command(argv);
    return 0;
}
