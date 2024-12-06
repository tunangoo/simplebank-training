package util

type Currency int

const (
	USD Currency = iota
	EUR
	CAD
)

func IsSupportedCurrency(currency string) bool {
	_, ok := CurrencyString(currency)
	return ok == nil
}
