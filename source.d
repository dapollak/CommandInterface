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

template makeCmd(T) {

string genAssigmentString(int numOfParams)() {
	string res = "";
	foreach (i; 0..numOfParams) {
		res ~= "to!(paramTypes["~to!string(i)~"])(args["~to!string(i+2)~"]), ";
	}

	return res[0..$-2];
}

void makeCmd(string[] args) {
	foreach (method; __traits(allMembers, T)) {
		if (args[1] == method) {

			mixin("enum int numOfParams = Parameters!("~fullyQualifiedName!T~"."~method~").length;");
			mixin("alias paramTypes = Parameters!("~fullyQualifiedName!T~"."~method~");");
			
			enum string assignmentString = genAssigmentString!numOfParams();
			mixin("writeln("~fullyQualifiedName!T~"."~method~"("~assignmentString~"));");
		}
	}
}

}

int main(string[] argv)
{
	makeCmd!Command(argv);
    return 0;
}
