#include <iostream>
#include <bitset>
#include <vector>
#include <cmath>


int main() {
	std::cout << "a | b | c | OR" << std::endl;
	const int size = 0;
	std::vector<int> places = {
		0, 0, 0
	};
	for(int i = 0; i < std::pow(places.size(), 2) - 1; i++) {
		std::string bin = std::bitset<3>(i).to_string();//is it possible to set the bitlength on-the-fly?
		for(int j = places.size() - 1; j >= 0; j--) {
			places.at(j) = bin[j] - 0x30;//lol
		}
		for(int k = 0; k < places.size(); k++) {
			std::cout << places.at(k) << " | ";
		}
		std::cout << ((places.at(0) ||//is it possible to create this equation on-the-fly?
					   places.at(1) ||
					   places.at(2) //||
					  ) ? 1 : 0) << std::endl;
	}
	return 0;
}
