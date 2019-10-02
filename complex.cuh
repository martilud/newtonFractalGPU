

struct complx {
	float re;
	float im;
	complx(float r, float i) : re(r), im(i);
};

float norm(cmplx &num) {
	return num.re*num.re + num.im * num.im;
}
const cmplx operator +(const cmplx &num1, const cmplx &num2) {
	return cmplx()
}