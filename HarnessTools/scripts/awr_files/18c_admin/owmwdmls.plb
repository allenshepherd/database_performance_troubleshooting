@@?/rdbms/admin/sqlsessstart.sql
create or replace package wmsys.owm_dml_pkg wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
ac3 35b
FLuIdv3Bw+JhsFN0/89nVBe/nqwwgzsrLcAFfHTNimSPyKi+2TJ97PSoqPQXGF03GsO/7iWY
y3niVZL4RAG6YWZtYfwRwvsG7Vt982GG4Nn2cJ21vGO7IJ0lT08kBNBrzPGhTYn7aEuVB5n7
GQrqsooyxhwd5UU5kRAev/nHmiLnnMOXsxefPh8fx2tpH6ceDto8lKKdEovKJ1huwG1dLjX1
uv5j2NoBuy9KbMtWXXq7p7fMb4fgwywO2pdDa59rk8ly+kPyFvVutwhI7mNC/kQTM+LDfeLD
l/gy+O+1tl4/gnpfXLPjDtg4OvGTpLq3dqPBLOWAbK82lJ8+inZLSowRVz9C4OeoUTiXNoU2
lscEhh3Al/iOVzu9FXuV6BFyR1scUSSZFu/u9ljHYL3oDPVXCuikYEVev3oS7WHW2MNYl8lr
aLMplHfXUOtrLkPeEJtNateKOwwqwLEaGQY82twKMqL9x42Lgc0YTUdSGugbddZ7Rp6veMrQ
lXKKuPWkRDdUVa9ssysMBqkgUKO+4F9N2ya7TOyOclnAlPBWrhAI31I7+gR7rE80kLabJ5ii
WGRp8RgErBGbefOIz+PLXnH09XwZ2PkGPeepQB7+vxFLpXuby1DrgMj4JsHLTWySTVmQFq2I
9yRPBPBe+g6jBAKHD/Jke7NyslcMbBdpjm+y43nlVhuIkCusW6XrtkGO3g6VlfDBEnMXtr7e
gNeYKL0vYkF+mDw4H26dxBDs7Q2E5JBj+N/e1WHrfYGhhzRqIrUsA0Bg488vV8k2/4F++2jX
Ioj4FIwKSIoqqq3WXcJciyR8gF52H8MJeZ83xWJQsgQ6myksyqGVRQ==

/
begin
  for trec in (select trigger_name from dba_triggers where owner = 'WMSYS') loop
    execute immediate 'drop trigger wmsys.' || trec.trigger_name ;
  end loop;
end;
/
@@?/rdbms/admin/sqlsessend.sql
