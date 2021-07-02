import { Agrupador, AgrupadorAlterarDto, AgrupadorInserirDto } from '@admin/domain';
import { AgrupadorService, JwtAuthGuard } from '@admin/services';
import { Body, Controller, Get, Param, Post, Put, Query, UseGuards, UsePipes, ValidationPipe } from '@nestjs/common';


@Controller('agrupador')
@UseGuards(JwtAuthGuard)
export class AgrupadorController {

  constructor(
    private readonly service: AgrupadorService
  ) { }

  @Get(':codigo')
  async get(@Param('codigo') codigo: number): Promise<Agrupador> {
    return await this.service.getById(codigo);
  }

  @Get()
  async pesquisar(@Query() filtros: Agrupador): Promise<Agrupador[]> {
    return await this.service.pesquisar(filtros);
  }

  @Post()
  @UsePipes(new ValidationPipe({ transform: true }))
  async inserir(@Body() agrupadorDto : AgrupadorInserirDto): Promise<Agrupador> {
    agrupadorDto.dataInclusao = new Date();
    agrupadorDto.ativo = true;
    return await this.service.inserir(agrupadorDto);
  }

  @Put(':id')
  @UsePipes(new ValidationPipe({ transform: true }))
  async alterar(@Param('codigo') codigo: number, @Body() agrupadorDto: AgrupadorAlterarDto): Promise<Agrupador> {
    return await this.service.alterar(codigo, agrupadorDto);
  }
}
